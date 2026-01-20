#!/usr/bin/env node

/**
 * Data Flow Tracker
 *
 * Tracks data flow through React components and API endpoints
 * to understand how information moves through the system
 */

import * as parser from '@typescript-eslint/parser';
import { TSESLint } from '@typescript-eslint/utils';
import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

class DataFlowTracker {
  constructor() {
    this.flows = new Map();
    this.stateFlows = new Map();
    this.apiFlows = new Map();
    this.propFlows = new Map();
  }

  /**
   * Parse a TypeScript file
   */
  parseFile(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf-8');
      return parser.parse(content, {
        sourceType: 'module',
        ecmaVersion: 2020,
        ecmaFeatures: {
          jsx: true
        }
      });
    } catch (error) {
      console.error(`Error parsing ${filePath}:`, error.message);
      return null;
    }
  }

  /**
   * Track React component data flows
   */
  trackComponentFlows(ast, filePath) {
    const componentFlows = {
      props: {},
      state: {},
      effects: [],
      events: [],
      dataTransformations: []
    };

    // Extract component name
    const componentName = path.basename(filePath, path.extname(filePath));

    // Track props usage
    TSESLint.SourceCode.prototype.traverse(ast, {
      FunctionDeclaration(node) {
        if (node.params && node.params[0]) {
          const propsParam = node.params[0];
          if (propsParam.type === 'ObjectPattern') {
            componentFlows.props = this.extractDestructuredProps(propsParam);
          }
        }
      },
      FunctionExpression(node) {
        if (node.params && node.params[0]) {
          const propsParam = node.params[0];
          if (propsParam.type === 'ObjectPattern') {
            componentFlows.props = this.extractDestructuredProps(propsParam);
          }
        }
      },
      ArrowFunctionExpression(node) {
        if (node.params && node.params[0]) {
          const propsParam = node.params[0];
          if (propsParam.type === 'ObjectPattern') {
            componentFlows.props = this.extractDestructuredProps(propsParam);
          }
        }
      }
    });

    // Track state usage and hooks
    TSESLint.SourceCode.prototype.traverse(ast, {
      CallExpression(node) {
        const callee = node.callee;

        // Track useState
        if (callee.type === 'Identifier' && callee.name === 'useState') {
          const stateVar = node.parent?.id?.name?.replace('set', '').toLowerCase();
          if (stateVar) {
            componentFlows.state[stateVar] = {
              type: this.inferTypeFromInitialization(node),
              updater: `set${stateVar.charAt(0).toUpperCase() + stateVar.slice(1)}`
            };
          }
        }

        // Track useEffect dependencies
        if (callee.type === 'Identifier' && callee.name === 'useEffect') {
          if (node.arguments[1] && node.arguments[1].type === 'ArrayExpression') {
            const dependencies = node.arguments[1].elements.map(
              el => el?.name || 'unknown'
            ).filter(name => name !== 'unknown');

            componentFlows.effects.push({
              dependencies,
              hasCleanup: node.arguments[0]?.body?.body?.some(
                stmt => stmt.type === 'ReturnStatement'
              )
            });
          }
        }

        // Track event handlers
        if (callee.type === 'Identifier' &&
            (callee.name.startsWith('handle') || callee.name.startsWith('on'))) {
          componentFlows.events.push({
            name: callee.name,
            line: node.loc.start.line
          });
        }

        // Track API calls
        if (callee.type === 'Identifier' &&
            (callee.name === 'fetch' || callee.name === 'axios')) {
          const apiCall = this.extractAPICall(node);
          if (apiCall) {
            componentFlows.dataTransformations.push(apiCall);
          }
        }
      }
    });

    // Track JSX prop passing
    TSESLint.SourceCode.prototype.traverse(ast, {
      JSXElement(node) {
        if (node.openingElement.name.type === 'JSXIdentifier') {
          const childComponent = node.openingElement.name.name;

          node.openingElement.attributes.forEach(attr => {
            if (attr.type === 'JSXAttribute' && attr.value?.type === 'JSXExpressionContainer') {
              const propName = attr.name.name;
              const propValue = this.extractPropValue(attr.value.expression);

              if (!this.propFlows.has(componentName)) {
                this.propFlows.set(componentName, []);
              }

              this.propFlows.get(componentName).push({
                to: childComponent,
                prop: propName,
                source: propValue
              });
            }
          });
        }
      }
    });

    return { componentName, flows: componentFlows };
  }

  /**
   * Track API endpoint data flows
   */
  trackAPIFlows(ast, filePath) {
    const apiFlow = {
      method: 'GET',
      path: '',
      inputs: [],
      outputs: [],
      transformations: [],
      dependencies: []
    };

    // Extract HTTP method and path from filename
    const fileName = path.basename(filePath, path.extname(filePath));
    if (fileName.includes('[') && fileName.includes(']')) {
      apiFlow.method = 'GET'; // Default for dynamic routes
      apiFlow.path = `/api/${fileName.replace(/(\[|\])/g, '')}`;
    } else {
      apiFlow.path = `/api/${fileName}`;
    }

    // Track request handling
    TSESLint.SourceCode.prototype.traverse(ast, {
      ExportDefaultDeclaration(node) {
        if (node.declaration?.type === 'FunctionDeclaration') {
          const handler = node.declaration;

          // Extract parameters (request, response)
          if (handler.params && handler.params[0]) {
            const reqParam = handler.params[0];
            if (reqParam.type === 'ObjectPattern') {
              apiFlow.inputs = this.extractRequestInputs(reqParam);
            }
          }

          // Track response patterns
          TSESTree.simpleTraverse(handler, {
            CallExpression(callNode) {
              const callee = callNode.callee;

              // Track res.json, res.status, etc.
              if (callee.type === 'MemberExpression' &&
                  callee.object?.name === 'res') {
                apiFlow.outputs.push({
                  type: callee.property?.name || 'response',
                  line: callNode.loc.start.line
                });
              }

              // Track database operations
              if (callee.object?.name === 'supabase') {
                apiFlow.dependencies.push({
                  type: 'supabase',
                  operation: this.extractSupabaseOperation(callNode),
                  line: callNode.loc.start.line
                });
              }

              // Track external API calls
              if (callee.object?.name === 'fetch' ||
                  callee.property?.name === 'generate' ||
                  callee.property?.name === 'create') {
                apiFlow.transformations.push({
                  type: 'external_api',
                  service: callee.object?.name || 'unknown',
                  line: callNode.loc.start.line
                });
              }
            }
          });
        }
      }
    });

    return apiFlow;
  }

  /**
   * Extract destructured props from object pattern
   */
  extractDestructuredProps(pattern) {
    const props = {};

    pattern.properties.forEach(prop => {
      if (prop.type === 'Property') {
        props[prop.key.name] = {
          type: prop.value.typeAnnotation ?
            this.getTypeString(prop.value.typeAnnotation.typeAnnotation) :
            'any',
          optional: prop.key.optional
        };
      }
    });

    return props;
  }

  /**
   * Extract request inputs from req object pattern
   */
  extractRequestInputs(reqPattern) {
    const inputs = [];

    reqPattern.properties.forEach(prop => {
      if (prop.type === 'Property') {
        inputs.push({
          name: prop.key.name,
          source: prop.key.name // body, query, params
        });
      }
    });

    return inputs;
  }

  /**
   * Extract Supabase operation details
   */
  extractSupabaseOperation(callNode) {
    const operation = {
      table: 'unknown',
      action: 'unknown'
    };

    if (callNode.callee.object?.property?.name === 'from') {
      operation.table = callNode.arguments[0]?.value || 'unknown';
      operation.action = callNode.callee.property?.name || 'unknown';
    }

    return operation;
  }

  /**
   * Extract prop value from expression
   */
  extractPropValue(expression) {
    if (expression.type === 'Identifier') {
      return expression.name;
    } else if (expression.type === 'MemberExpression') {
      return `${expression.object.name}.${expression.property.name}`;
    } else if (expression.type === 'CallExpression') {
      return 'function()';
    }
    return 'value';
  }

  /**
   * Extract API call details
   */
  extractAPICall(node) {
    if (node.arguments[0]?.type === 'Literal') {
      return {
        url: node.arguments[0].value,
        method: 'GET', // Default, could be enhanced
        line: node.loc.start.line
      };
    }
    return null;
  }

  /**
   * Infer type from useState initialization
   */
  inferTypeFromInitialization(node) {
    if (node.parent?.init) {
      const init = node.parent.init;
      if (init.type === 'Literal') {
        return typeof init.value;
      } else if (init.type === 'ArrayExpression') {
        return 'array';
      } else if (init.type === 'ObjectExpression') {
        return 'object';
      }
    }
    return 'any';
  }

  /**
   * Convert AST type node to string
   */
  getTypeString(typeNode) {
    if (!typeNode) return 'any';

    switch (typeNode.type) {
      case 'TSStringKeyword': return 'string';
      case 'TSNumberKeyword': return 'number';
      case 'TSBooleanKeyword': return 'boolean';
      case 'TSArrayType': return `${this.getTypeString(typeNode.elementType)}[]`;
      case 'TSUnionType':
        return typeNode.types.map(t => this.getTypeString(t)).join(' | ');
      case 'TSTypeReference': return typeNode.typeName.name;
      default: return 'any';
    }
  }

  /**
   * Analyze all files and build data flow map
   */
  analyzeDataFlow() {
    const components = glob.sync('components/**/*.{ts,tsx}');
    const apis = glob.sync('pages/api/**/*.{ts,tsx}');

    // Analyze component flows
    components.forEach(file => {
      const ast = this.parseFile(file);
      if (ast) {
        const { componentName, flows } = this.trackComponentFlows(ast, file);
        this.flows.set(componentName, {
          type: 'component',
          file,
          ...flows
        });
      }
    });

    // Analyze API flows
    apis.forEach(file => {
      const ast = this.parseFile(file);
      if (ast) {
        const apiFlow = this.trackAPIFlows(ast, file);
        const apiName = path.basename(file, path.extname(file));
        this.apiFlows.set(apiName, {
          ...apiFlow,
          file
        });
      }
    });

    return this.buildFlowReport();
  }

  /**
   * Build comprehensive data flow report
   */
  buildFlowReport() {
    const report = {
      summary: {
        totalComponents: 0,
        totalAPIs: 0,
        totalStateVariables: 0,
        totalEventHandlers: 0
      },
      components: {},
      apis: {},
      dataFlows: [],
      patterns: []
    };

    // Process components
    this.flows.forEach((flow, name) => {
      report.summary.totalComponents++;
      report.summary.totalStateVariables += Object.keys(flow.state).length;
      report.summary.totalEventHandlers += flow.events.length;

      report.components[name] = {
        file: flow.file,
        props: flow.props,
        state: flow.state,
        events: flow.events,
        transformations: flow.dataTransformations
      };
    });

    // Process APIs
    this.apiFlows.forEach((flow, name) => {
      report.summary.totalAPIs++;
      report.apis[name] = flow;
    });

    // Build data flow chains
    this.propFlows.forEach((flows, fromComponent) => {
      flows.forEach(flow => {
        report.dataFlows.push({
          from: fromComponent,
          to: flow.to,
          via: flow.prop,
          data: flow.source
        });
      });
    });

    // Extract common patterns
    report.patterns = this.extractPatterns();

    return report;
  }

  /**
   * Extract common data flow patterns
   */
  extractPatterns() {
    const patterns = [];

    // Pattern 1: Character upload flow
    patterns.push({
      name: 'Character Upload Flow',
      description: 'File upload → compression → Supabase storage → state update',
      components: ['ImageUpload', 'CharacterCard'],
      apis: ['storage/upload'],
      steps: [
        'User selects image',
        'compressImage() is called',
        'uploadToSupabase() stores file',
        'URL is saved to state',
        'Component re-renders with new image'
      ]
    });

    // Pattern 2: API response handling
    patterns.push({
      name: 'API Response Handling',
      description: 'Fetch → error handling → state update → UI refresh',
      components: ['various'],
      apis: ['various'],
      steps: [
        'Component makes API call',
        'Loading state is set',
        'Response is received',
        'Success/error handling',
        'State is updated',
        'UI re-renders'
      ]
    });

    // Pattern 3: Form submission
    patterns.push({
      name: 'Form Submission Flow',
      description: 'Form input → validation → API call → response handling',
      components: ['Form components'],
      apis: ['POST/PUT endpoints'],
      steps: [
        'User fills form',
        'Validation occurs',
        'Submit handler called',
        'API request made',
        'Response processed',
        'UI updated or redirected'
      ]
    });

    return patterns;
  }

  /**
   * Generate markdown report
   */
  generateMarkdownReport(report) {
    let markdown = '# Data Flow Analysis Report\n\n';
    markdown += `Generated on: ${new Date().toISOString()}\n\n`;

    // Summary
    markdown += '## Summary\n\n';
    markdown += `- **Total Components**: ${report.summary.totalComponents}\n`;
    markdown += `- **Total APIs**: ${report.summary.totalAPIs}\n`;
    markdown += `- **State Variables**: ${report.summary.totalStateVariables}\n`;
    markdown += `- **Event Handlers**: ${report.summary.totalEventHandlers}\n\n`;

    // Data Flow Chains
    markdown += '## Data Flow Chains\n\n';
    report.dataFlows.forEach(flow => {
      markdown += `### ${flow.from} → ${flow.to}\n`;
      markdown += `- **Via**: \`${flow.via}\`\n`;
      markdown += `- **Data**: \`${flow.data}\`\n\n`;
    });

    // Common Patterns
    markdown += '## Common Data Flow Patterns\n\n';
    report.patterns.forEach(pattern => {
      markdown += `### ${pattern.name}\n`;
      markdown += `${pattern.description}\n\n`;
      markdown += '**Components**: ';
      markdown += pattern.components.join(', ') + '\n\n';
      markdown += '**Steps**:\n';
      pattern.steps.forEach((step, i) => {
        markdown += `${i + 1}. ${step}\n`;
      });
      markdown += '\n';
    });

    return markdown;
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const tracker = new DataFlowTracker();
  const report = tracker.analyzeDataFlow();

  console.log('Analyzing data flows...');

  const outputDir = '.claude/generated';
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const reportPath = path.join(outputDir, 'data-flow-report.md');
  const markdown = tracker.generateMarkdownReport(report);

  fs.writeFileSync(reportPath, markdown);
  console.log(`Data flow report generated: ${reportPath}`);

  // Also output JSON for programmatic use
  const jsonPath = path.join(outputDir, 'data-flow-analysis.json');
  fs.writeFileSync(jsonPath, JSON.stringify(report, null, 2));
  console.log(`JSON analysis saved: ${jsonPath}`);
}

export default DataFlowTracker;