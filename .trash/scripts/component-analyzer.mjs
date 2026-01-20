#!/usr/bin/env node

/**
 * Component Intelligence Analyzer
 *
 * This script performs deep analysis of React components to extract:
 * - Props interfaces with detailed type information
 * - State management patterns
 * - Custom hook usage
 * - Event handler chains
 * - Performance characteristics
 * - Dependencies and relationships
 */

const { parse } = require('@typescript-eslint/parser');
const { TSESTree } = require('@typescript-eslint/typescript-estree');
const fs = require('fs');
const path = require('path');
const glob = require('glob');

class ComponentAnalyzer {
  constructor() {
    this.components = new Map();
    this.hooks = new Map();
    this.events = new Map();
    this.state = new Map();
  }

  /**
   * Analyze a React component file
   */
  analyzeComponent(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf-8');
      const ast = parse(content, {
        sourceType: 'module',
        ecmaVersion: 2020,
        ecmaFeatures: {
          jsx: true
        }
      });

      return this.extractComponentInfo(ast, filePath);
    } catch (error) {
      console.error(`Error analyzing ${filePath}:`, error.message);
      return null;
    }
  }

  /**
   * Extract comprehensive component information
   */
  extractComponentInfo(ast, filePath) {
    const component = {
      file: filePath,
      name: path.basename(filePath, '.tsx'),
      exports: [],
      imports: [],
      props: {},
      state: [],
      hooks: [],
      events: [],
      effects: [],
      context: [],
      performance: {
        memo: false,
        callback: [],
        useMemo: []
      },
      dependencies: {
        external: [],
        internal: [],
        hooks: []
      },
      children: []
    };

    // Extract imports
    TSESTree.simpleTraverse(ast, {
      ImportDeclaration(node) {
        const importInfo = {
          source: node.source.value,
          isExternal: !node.source.value.startsWith('.'),
          specifiers: []
        };

        node.specifiers.forEach(spec => {
          if (spec.type === 'ImportDefaultSpecifier') {
            importInfo.specifiers.push({
              name: spec.local.name,
              type: 'default'
            });
          } else if (spec.type === 'ImportSpecifier') {
            importInfo.specifiers.push({
              name: spec.local.name,
              imported: spec.imported.name,
              type: 'named'
            });
          } else if (spec.type === 'ImportNamespaceSpecifier') {
            importInfo.specifiers.push({
              name: spec.local.name,
              type: 'namespace'
            });
          }
        });

        component.imports.push(importInfo);

        // Track dependencies
        if (importInfo.isExternal) {
          component.dependencies.external.push(importInfo.source);
        }
      }
    });

    // Find component exports
    TSESTree.simpleTraverse(ast, {
      ExportNamedDeclaration(node) {
        if (node.declaration) {
          if (node.declaration.type === 'FunctionDeclaration' && node.declaration.id) {
            component.exports.push({
              name: node.declaration.id.name,
              type: 'function',
              isComponent: this.isReactComponent(node.declaration)
            });
          } else if (node.declaration.type === 'VariableDeclaration') {
            node.declaration.declarations.forEach(decl => {
              if (decl.init && this.isReactComponent(decl.init)) {
                component.exports.push({
                  name: decl.id.name,
                  type: 'variable',
                  isComponent: true
                });
              }
            });
          }
        }
      },
      ExportDefaultDeclaration(node) {
        if (node.declaration) {
          let name = 'default';
          if (node.declaration.type === 'Identifier') {
            name = node.declaration.name;
          } else if (node.declaration.id) {
            name = node.declaration.id.name;
          } else if (node.declaration.type === 'FunctionDeclaration' && node.declaration.id) {
            name = node.declaration.id.name;
          }

          component.exports.push({
            name,
            type: 'default',
            isComponent: this.isReactComponent(node.declaration)
          });
        }
      }
    });

    // Analyze each exported component
    component.exports.forEach(exp => {
      if (exp.isComponent) {
        this.analyzeComponentDeclaration(ast, component, exp.name);
      }
    });

    return component;
  }

  /**
   * Check if a node represents a React component
   */
  isReactComponent(node) {
    // Check for JSX in return statements
    let hasJSX = false;

    const checkNode = (n) => {
      if (n.type === 'ReturnStatement' && n.argument) {
        if (n.argument.type === 'JSXElement' ||
            n.argument.type === 'JSXFragment' ||
            (n.argument.type === 'ConditionalExpression' &&
             (this.hasJSX(n.argument.consequent) || this.hasJSX(n.argument.alternate)))) {
          hasJSX = true;
        }
      }
    };

    TSESTree.simpleTraverse(node, {
      ReturnStatement: checkNode
    });

    return hasJSX;
  }

  /**
   * Check if node contains JSX
   */
  hasJSX(node) {
    if (!node) return false;
    if (node.type === 'JSXElement' || node.type === 'JSXFragment') return true;

    let has = false;
    TSESTree.simpleTraverse(node, {
      JSXElement: () => { has = true; },
      JSXFragment: () => { has = true; }
    });
    return has;
  }

  /**
   * Analyze component declaration
   */
  analyzeComponentDeclaration(ast, component, componentName) {
    let componentNode = null;

    // Find the component node
    TSESTree.simpleTraverse(ast, {
      FunctionDeclaration(node) {
        if (node.id && node.id.name === componentName) {
          componentNode = node;
        }
      },
      VariableDeclarator(node) {
        if (node.id && node.id.name === componentName) {
          componentNode = node.init;
        }
      }
    });

    if (!componentNode) return;

    // Extract props
    this.extractProps(componentNode, component);

    // Extract hooks
    this.extractHooks(componentNode, component);

    // Extract state
    this.extractState(componentNode, component);

    // Extract events
    this.extractEvents(componentNode, component);

    // Extract effects
    this.extractEffects(componentNode, component);

    // Extract context
    this.extractContext(componentNode, component);

    // Extract performance patterns
    this.extractPerformancePatterns(componentNode, component);

    // Extract children components
    this.extractChildren(componentNode, component);
  }

  /**
   * Extract props from component
   */
  extractProps(node, component) {
    if (node.params && node.params[0]) {
      const firstParam = node.params[0];

      if (firstParam.type === 'ObjectPattern') {
        // Destructured props: ({ name, age }) => {}
        const props = {};
        firstParam.properties.forEach(prop => {
          if (prop.type === 'Property') {
            props[prop.key.name] = {
              type: prop.value.typeAnnotation ?
                this.getTypeString(prop.value.typeAnnotation.typeAnnotation) :
                'any',
              optional: prop.optional,
              defaultValue: prop.value.type === 'AssignmentPattern' ?
                this.getValueString(prop.value.right) : null
            };
          }
        });
        component.props = { type: 'destructured', properties: props };
      } else if (firstParam.typeAnnotation) {
        // Typed props: (props: MyProps) => {}
        component.props = {
          type: 'typed',
          interface: this.getTypeString(firstParam.typeAnnotation.typeAnnotation),
          name: firstParam.typeAnnotation.typeAnnotation.typeName?.name || 'Props'
        };
      } else {
        component.props = { type: 'untyped' };
      }
    }
  }

  /**
   * Extract React hooks usage
   */
  extractHooks(node, component) {
    TSESTree.simpleTraverse(node, {
      CallExpression(callNode) {
        const callee = callNode.callee;

        if (callee.type === 'Identifier' && callee.name.startsWith('use')) {
          const hookInfo = {
            name: callee.name,
            line: callNode.loc.start.line,
            args: callNode.arguments.map(arg => this.getValueString(arg)),
            returnType: this.inferHookReturnType(callee.name, callNode)
          };
          component.hooks.push(hookInfo);
        } else if (callee.type === 'MemberExpression' &&
                   callee.object.type === 'Identifier' &&
                   callee.object.name === 'React' &&
                   callee.property.type === 'Identifier' &&
                   callee.property.name.startsWith('use')) {
          const hookInfo = {
            name: `React.${callee.property.name}`,
            line: callNode.loc.start.line,
            args: callNode.arguments.map(arg => this.getValueString(arg)),
            returnType: this.inferHookReturnType(callee.property.name, callNode)
          };
          component.hooks.push(hookInfo);
        }
      }
    });
  }

  /**
   * Extract state usage patterns
   */
  extractState(node, component) {
    TSESTree.simpleTraverse(node, {
      CallExpression(callNode) {
        const callee = callNode.callee;

        if (callee.type === 'Identifier' && callee.name === 'useState') {
          const stateInfo = {
            line: callNode.loc.start.line,
            initialValue: callNode.arguments.length > 0 ?
              this.getValueString(callNode.arguments[0]) : 'undefined',
            updater: null
          };

          // Try to find the updater function
          if (callNode.parent && callNode.parent.type === 'VariableDeclarator') {
            if (callNode.parent.id && callNode.parent.id.type === 'ArrayPattern') {
              stateInfo.stateVar = callNode.parent.id.elements[0]?.name;
              stateInfo.updaterVar = callNode.parent.id.elements[1]?.name;
            }
          }

          component.state.push(stateInfo);
        } else if (callee.type === 'Identifier' && callee.name === 'useReducer') {
          component.state.push({
            line: callNode.loc.start.line,
            type: 'reducer',
            initialValue: callNode.arguments[1] ? this.getValueString(callNode.arguments[1]) : undefined
          });
        }
      }
    });
  }

  /**
   * Extract event handlers
   */
  extractEvents(node, component) {
    TSESTree.simpleTraverse(node, {
      FunctionDeclaration(funcNode) {
        if (funcNode.id && this.isEventHandlerName(funcNode.id.name)) {
          component.events.push({
            name: funcNode.id.name,
            line: funcNode.loc.start.line,
            type: 'function',
            params: funcNode.params.map(p => p.name)
          });
        }
      },
      VariableDeclarator(varNode) {
        if (varNode.id && this.isEventHandlerName(varNode.id.name)) {
          component.events.push({
            name: varNode.id.name,
            line: varNode.loc.start.line,
            type: 'variable',
            params: varNode.init && varNode.init.params ?
              varNode.init.params.map(p => p.name) : []
          });
        }
      }
    });
  }

  /**
   * Extract useEffect usage
   */
  extractEffects(node, component) {
    TSESTree.simpleTraverse(node, {
      CallExpression(callNode) {
        const callee = callNode.callee;

        if (callee.type === 'Identifier' && callee.name === 'useEffect') {
          const effect = {
            line: callNode.loc.start.line,
            dependencies: [],
            hasCleanup: false
          };

          if (callNode.arguments.length > 1) {
            // Extract dependencies array
            const depsArray = callNode.arguments[1];
            if (depsArray.type === 'ArrayExpression') {
              effect.dependencies = depsArray.elements.map(elem =>
                elem ? this.getValueString(elem) : null
              );
            }
          }

          // Check for cleanup function
          if (callNode.arguments.length > 0) {
            const effectFn = callNode.arguments[0];
            if (effectFn.body) {
              TSESTree.simpleTraverse(effectFn, {
                ReturnStatement(retNode) {
                  if (retNode.argument) {
                    effect.hasCleanup = true;
                  }
                }
              });
            }
          }

          component.effects.push(effect);
        }
      }
    });
  }

  /**
   * Extract useContext usage
   */
  extractContext(node, component) {
    TSESTree.simpleTraverse(node, {
      CallExpression(callNode) {
        const callee = callNode.callee;

        if (callee.type === 'Identifier' && callee.name === 'useContext') {
          component.context.push({
            line: callNode.loc.start.line,
            contextType: callNode.arguments[0] ?
              this.getValueString(callNode.arguments[0]) : 'unknown'
          });
        }
      }
    });
  }

  /**
   * Extract performance optimization patterns
   */
  extractPerformancePatterns(node, component) {
    TSESTree.simpleTraverse(node, {
      CallExpression(callNode) {
        const callee = callNode.callee;

        if (callee.type === 'Identifier' && callee.name === 'React') {
          // Check for React.memo in JSX
          // This would be in the parent scope
        }
      },
      Identifier(idNode) {
        if (idNode.name === 'useCallback') {
          component.performance.callback.push({
            line: idNode.loc.start.line
          });
        } else if (idNode.name === 'useMemo') {
          component.performance.useMemo.push({
            line: idNode.loc.start.line
          });
        }
      }
    });

    // Check for React.memo wrapper
    TSESTree.simpleTraverse(node.parent || node, {
      CallExpression(callNode) {
        if (callNode.callee.type === 'MemberExpression' &&
            callNode.callee.object.name === 'React' &&
            callNode.callee.property.name === 'memo') {
          component.performance.memo = true;
        }
      }
    });
  }

  /**
   * Extract child components used
   */
  extractChildren(node, component) {
    const children = new Set();

    TSESTree.simpleTraverse(node, {
      JSXOpeningElement(element) {
        if (element.name.type === 'JSXIdentifier') {
          const componentName = element.name.name;

          // Check if it's a component (starts with uppercase)
          if (componentName[0] === componentName[0].toUpperCase()) {
            children.add({
              name: componentName,
              line: element.loc.start.line,
              props: element.attributes.map(attr => ({
                name: attr.name.name,
                type: attr.value ? (attr.value.type === 'Literal' ? 'literal' : 'expression') : 'boolean'
              }))
            });
          }
        }
      }
    });

    component.children = Array.from(children);
  }

  /**
   * Check if name suggests an event handler
   */
  isEventHandlerName(name) {
    return name.startsWith('handle') || name.startsWith('on') || name.endsWith('Handler');
  }

  /**
   * Infer hook return type
   */
  inferHookReturnType(hookName, callNode) {
    const commonHooks = {
      useState: 'Array',
      useEffect: 'void',
      useContext: 'any',
      useRef: 'Object',
      useMemo: 'any',
      useCallback: 'Function',
      useReducer: 'Array'
    };

    return commonHooks[hookName] || 'unknown';
  }

  /**
   * Get type string from type annotation
   */
  getTypeString(typeNode) {
    if (!typeNode) return 'any';

    switch (typeNode.type) {
      case 'TSStringKeyword':
        return 'string';
      case 'TSNumberKeyword':
        return 'number';
      case 'TSBooleanKeyword':
        return 'boolean';
      case 'TSArrayType':
        return `${this.getTypeString(typeNode.elementType)}[]`;
      case 'TSUnionType':
        return typeNode.types.map(t => this.getTypeString(t)).join(' | ');
      case 'TSTypeReference':
        let name = typeNode.typeName.name;
        if (typeNode.typeParameters) {
          const params = typeNode.typeParameters.params.map(p => this.getTypeString(p));
          name += `<${params.join(', ')}>`;
        }
        return name;
      default:
        return 'any';
    }
  }

  /**
   * Get value string from AST node
   */
  getValueString(node) {
    if (!node) return 'undefined';

    switch (node.type) {
      case 'Literal':
        return JSON.stringify(node.value);
      case 'Identifier':
        return node.name;
      case 'StringLiteral':
        return node.value;
      case 'NumericLiteral':
        return node.value.toString();
      case 'BooleanLiteral':
        return node.value.toString();
      case 'NullLiteral':
        return 'null';
      case 'ArrayExpression':
        const elements = node.elements.map(e => this.getValueString(e));
        return `[${elements.join(', ')}]`;
      case 'ObjectExpression':
        const properties = node.properties.map(p =>
          `${p.key.name}: ${this.getValueString(p.value)}`
        );
        return `{ ${properties.join(', ')} }`;
      default:
        return node.type;
    }
  }

  /**
   * Analyze multiple component files
   */
  analyzeFiles(pattern) {
    const files = glob.sync(pattern, {
      cwd: process.cwd(),
      absolute: true
    });

    const results = [];

    for (const file of files) {
      const analysis = this.analyzeComponent(file);
      if (analysis) {
        results.push(analysis);
      }
    }

    return results;
  }

  /**
   * Generate detailed component documentation
   */
  generateDocumentation(analyses) {
    let documentation = `# Component Intelligence Report\n\n`;
    documentation += `*Generated on ${new Date().toISOString()}*\n\n`;

    analyses.forEach(comp => {
      documentation += `## ${comp.name}\n\n`;
      documentation += `**File**: \`${comp.file}\`\n\n`;

      if (comp.exports.length > 0) {
        documentation += `### Exports\n\n`;
        comp.exports.forEach(exp => {
          documentation += `- **${exp.name}** (${exp.type})${exp.isComponent ? ' [Component]' : ''}\n`;
        });
        documentation += '\n';
      }

      if (comp.props.type !== 'none') {
        documentation += `### Props\n\n`;
        if (comp.props.type === 'typed') {
          documentation += `Type: \`${comp.props.interface}\`\n\n`;
        } else if (comp.props.type === 'destructured') {
          documentation += `Destructured Props:\n\n`;
          Object.entries(comp.props.properties).forEach(([name, info]) => {
            documentation += `- \`${name}\`: ${info.type}${info.optional ? ' (optional)' : ''}\n`;
          });
        }
        documentation += '\n';
      }

      if (comp.hooks.length > 0) {
        documentation += `### Hooks Used\n\n`;
        comp.hooks.forEach(hook => {
          documentation += `- \`${hook.name}\` (line ${hook.line})\n`;
        });
        documentation += '\n';
      }

      if (comp.state.length > 0) {
        documentation += `### State Management\n\n`;
        comp.state.forEach(state => {
          if (state.type === 'reducer') {
            documentation += `- useReducer (line ${state.line})\n`;
          } else {
            documentation += `- useState (line ${state.line}) - Initial: ${state.initialValue}\n`;
          }
        });
        documentation += '\n';
      }

      if (comp.children.length > 0) {
        documentation += `### Child Components\n\n`;
        comp.children.forEach(child => {
          documentation += `- \`${child.name}\` (line ${child.line})\n`;
        });
        documentation += '\n';
      }

      documentation += `---\n\n`;
    });

    return documentation;
  }

  /**
   * Generate JSON output for programmatic use
   */
  generateJSON(analyses) {
    return {
      timestamp: new Date().toISOString(),
      totalComponents: analyses.length,
      components: analyses
    };
  }
}

// CLI interface
if (require.main === module) {
  const { Command } = require('commander');
  const chalk = require('chalk');
  const ora = require('ora');

  const program = new Command();

  program
    .name('component-analyzer')
    .description('Analyze React components for detailed intelligence')
    .option('-p, --pattern <pattern>', 'Glob pattern for component files', 'components/**/*.tsx')
    .option('-o, --output <file>', 'Output file for analysis results')
    .option('-f, --format <format>', 'Output format (json|markdown)', 'json')
    .option('-s, --summary', 'Show summary only')
    .parse();

  const options = program.opts();

  const spinner = ora('Analyzing components...').start();

  const analyzer = new ComponentAnalyzer();
  const analyses = analyzer.analyzeFiles(options.pattern);

  spinner.succeed(`Analyzed ${analyses.length} components`);

  if (options.summary) {
    const summary = {
      total: analyses.length,
      withHooks: analyses.filter(c => c.hooks.length > 0).length,
      withState: analyses.filter(c => c.state.length > 0).length,
      withEffects: analyses.filter(c => c.effects.length > 0).length,
      optimized: analyses.filter(c => c.performance.memo || c.performance.callback.length > 0).length
    };

    console.log(chalk.blue('\n## Component Analysis Summary\n'));
    console.log(`- **Total Components**: ${summary.total}`);
    console.log(`- **Using Hooks**: ${summary.withHooks}`);
    console.log(`- **With State**: ${summary.withState}`);
    console.log(`- **With Effects**: ${summary.withEffects}`);
    console.log(`- **Performance Optimized**: ${summary.optimized}`);
  } else {
    if (options.format === 'markdown') {
      const docs = analyzer.generateDocumentation(analyses);
      if (options.output) {
        fs.writeFileSync(options.output, docs);
        console.log(chalk.green(`Documentation saved to ${options.output}`));
      } else {
        console.log(docs);
      }
    } else {
      const json = analyzer.generateJSON(analyses);
      if (options.output) {
        fs.writeFileSync(options.output, JSON.stringify(json, null, 2));
        console.log(chalk.green(`Results saved to ${options.output}`));
      } else {
        console.log(JSON.stringify(json, null, 2));
      }
    }
  }
}

module.exports = ComponentAnalyzer;