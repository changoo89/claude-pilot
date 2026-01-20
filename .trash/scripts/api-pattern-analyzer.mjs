#!/usr/bin/env node

/**
 * API Pattern Analyzer
 *
 * Analyzes API endpoints and their usage patterns across the codebase
 * to understand request/response structures and common patterns
 */

import { parse } from '@typescript-eslint/parser';
import { TSESTree } from '@typescript-eslint/typescript-estree';
import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

class APIPatternAnalyzer {
  constructor() {
    this.endpoints = new Map();
    this.clients = new Map();
    this.schemas = new Map();
    this.patterns = [];
  }

  /**
   * Parse a TypeScript file
   */
  parseFile(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf-8');
      return parse(content, {
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
   * Analyze API endpoint definitions
   */
  analyzeEndpoints(filePath) {
    const ast = this.parseFile(filePath);
    if (!ast) return null;

    const endpointInfo = {
      path: this.extractPathFromFilename(filePath),
      method: 'GET',
      parameters: [],
      requestBody: null,
      responses: [],
      middleware: [],
      operations: [],
      dependencies: []
    };

    // Determine HTTP method and path
    TSESTree.simpleTraverse(ast, {
      ExportDefaultDeclaration(node) {
        if (node.declaration?.type === 'FunctionDeclaration') {
          const handler = node.declaration;

          // Check HTTP method annotations or patterns
          endpointInfo.method = this.inferHTTPMethod(handler, filePath);

          // Extract parameters from function signature
          if (handler.params) {
            handler.params.forEach((param, index) => {
              if (param.type === 'ObjectPattern') {
                endpointInfo.parameters.push({
                  name: ['req', 'res'][index] || `param${index}`,
                  properties: this.extractObjectProperties(param)
                });
              } else if (param.type === 'Identifier') {
                endpointInfo.parameters.push({
                  name: param.name,
                  type: 'unknown'
                });
              }
            });
          }

          // Analyze handler body for operations
          this.analyzeHandlerBody(handler, endpointInfo);
        }
      }
    });

    return endpointInfo;
  }

  /**
   * Analyze API client usage in components
   */
  analyzeClientUsage(filePath) {
    const ast = this.parseFile(filePath);
    if (!ast) return null;

    const clientUsage = {
      file: filePath,
      endpoints: [],
      patterns: [],
      errorHandling: [],
      authentication: []
    };

    TSESTree.simpleTraverse(ast, {
      CallExpression(node) {
        const callee = node.callee;

        // Fetch calls
        if (callee.type === 'Identifier' && callee.name === 'fetch') {
          const fetchInfo = this.extractFetchInfo(node);
          if (fetchInfo) {
            clientUsage.endpoints.push(fetchInfo);
          }
        }

        // Axios calls (if used)
        if (callee.type === 'MemberExpression' &&
            callee.object?.name === 'axios') {
          const axiosInfo = this.extractAxiosInfo(node);
          if (axiosInfo) {
            clientUsage.endpoints.push(axiosInfo);
          }
        }

        // Custom API functions
        if (callee.type === 'Identifier' &&
            (callee.name.startsWith('api') ||
             callee.name.includes('fetch') ||
             callee.name.includes('request'))) {
          clientUsage.endpoints.push({
            type: 'custom_function',
            function: callee.name,
            line: node.loc.start.line
          });
        }
      },

      // Try-catch blocks for error handling
      TryStatement(node) {
        clientUsage.errorHandling.push({
          type: 'try_catch',
          line: node.loc.start.line,
          hasFinally: !!node.finalizer
        });
      },

      // Promise.catch() for error handling
      CallExpression(node) {
        if (node.callee.type === 'MemberExpression' &&
            node.callee.property.name === 'catch') {
          clientUsage.errorHandling.push({
            type: 'promise_catch',
            line: node.loc.start.line
          });
        }
      }
    });

    return clientUsage;
  }

  /**
   * Extract API path from filename
   */
  extractPathFromFilename(filePath) {
    const relativePath = path.relative(process.cwd(), filePath);
    if (relativePath.startsWith('pages/api/')) {
      const apiPath = relativePath.replace('pages/api', '').replace(/\.(ts|tsx)$/, '');
      // Handle dynamic routes [id] -> :id
      return `/api${apiPath.replace(/\[([^\]]+)\]/g, ':$1')}`;
    }
    return relativePath;
  }

  /**
   * Infer HTTP method from file or handler patterns
   */
  inferHTTPMethod(handler, filePath) {
    // Check filename for method hints
    const filename = path.basename(filePath).toLowerCase();
    if (filename.includes('create') || filename.includes('post')) {
      return 'POST';
    }
    if (filename.includes('update') || filename.includes('put')) {
      return 'PUT';
    }
    if (filename.includes('delete') || filename.includes('remove')) {
      return 'DELETE';
    }
    if (filename.includes('patch')) {
      return 'PATCH';
    }

    // Check handler body for method checks
    let method = 'GET'; // default
    TSESTree.simpleTraverse(handler, {
      IfStatement(node) {
        if (node.test.type === 'MemberExpression' &&
            node.test.object?.property?.name === 'method') {
          if (node.test.type === 'BinaryExpression' &&
              node.test.right?.type === 'Literal') {
            method = node.test.right.value.toUpperCase();
          }
        }
      }
    });

    return method;
  }

  /**
   * Extract properties from object pattern
   */
  extractObjectProperties(pattern) {
    const properties = [];
    pattern.properties.forEach(prop => {
      if (prop.type === 'Property') {
        properties.push({
          name: prop.key.name,
          type: prop.value.typeAnnotation ?
            this.getTypeString(prop.value.typeAnnotation.typeAnnotation) :
            'any'
        });
      }
    });
    return properties;
  }

  /**
   * Analyze handler body for operations
   */
  analyzeHandlerBody(handler, endpointInfo) {
    TSESTree.simpleTraverse(handler, {
      CallExpression(node) {
        const callee = node.callee;

        // Supabase operations
        if (callee.type === 'MemberExpression' &&
            callee.object?.name === 'supabase') {
          endpointInfo.operations.push({
            type: 'supabase',
            operation: this.extractSupabaseOperation(node),
            line: node.loc.start.line
          });
        }

        // Database queries
        if (callee.object?.name === 'db' ||
            callee.property?.name === 'query') {
          endpointInfo.operations.push({
            type: 'database',
            operation: callee.property?.name || 'unknown',
            line: node.loc.start.line
          });
        }

        // External API calls
        if (callee.object?.name === 'fetch' ||
            callee.object?.name === 'axios') {
          endpointInfo.operations.push({
            type: 'external_api',
            service: 'unknown',
            line: node.loc.start.line
          });
        }

        // File operations
        if (callee.property?.name?.includes('upload') ||
            callee.property?.name?.includes('delete') ||
            callee.property?.name?.includes('storage')) {
          endpointInfo.operations.push({
            type: 'storage',
            operation: callee.property?.name,
            line: node.loc.start.line
          });
        }

        // Response sending
        if (callee.type === 'MemberExpression' &&
            callee.object?.name === 'res') {
          endpointInfo.responses.push({
            type: callee.property?.name || 'response',
            line: node.loc.start.line
          });
        }
      },

      // Await expressions for async operations
      AwaitExpression(node) {
        if (node.argument.type === 'CallExpression') {
          endpointInfo.dependencies.push({
            type: 'async_dependency',
            line: node.loc.start.line
          });
        }
      }
    });
  }

  /**
   * Extract Supabase operation details
   */
  extractSupabaseOperation(node) {
    const operation = {
      table: 'unknown',
      action: 'unknown',
      filters: []
    };

    // Track table name
    if (node.callee.property?.name === 'from' && node.arguments[0]) {
      operation.table = node.arguments[0].value || 'unknown';
    }

    // Track method chain
    if (node.callee.object?.property) {
      operation.action = node.callee.object.property.name;
    }

    // Track filters in .eq(), .in(), etc.
    if (node.callee.object?.object?.property) {
      operation.filters.push({
        method: node.callee.object.property.name
      });
    }

    return operation;
  }

  /**
   * Extract fetch call information
   */
  extractFetchInfo(node) {
    if (node.arguments[0]) {
      const url = node.arguments[0].type === 'Literal' ?
        node.arguments[0].value : 'dynamic';

      const options = node.arguments[1] || {};
      const method = this.extractMethodFromOptions(options);

      return {
        type: 'fetch',
        url,
        method: method || 'GET',
        line: node.loc.start.line
      };
    }
    return null;
  }

  /**
   * Extract axios call information
   */
  extractAxiosInfo(node) {
    return {
      type: 'axios',
      method: node.callee.property?.name || 'request',
      url: node.arguments[0]?.value || 'dynamic',
      line: node.loc.start.line
    };
  }

  /**
   * Extract HTTP method from fetch options
   */
  extractMethodFromOptions(options) {
    if (options.type === 'ObjectExpression') {
      const methodProp = options.properties.find(
        p => p.key?.name === 'method'
      );
      if (methodProp?.value?.value) {
        return methodProp.value.value.toUpperCase();
      }
    }
    return null;
  }

  /**
   * Convert AST type to string
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
   * Analyze all API patterns in the codebase
   */
  analyzeAll() {
    const apiFiles = glob.sync('pages/api/**/*.{ts,tsx}');
    const componentFiles = glob.sync('components/**/*.{ts,tsx}');
    const libFiles = glob.sync('lib/**/*.{ts,tsx}');

    // Analyze endpoints
    apiFiles.forEach(file => {
      const endpoint = this.analyzeEndpoints(file);
      if (endpoint) {
        const name = path.basename(file, path.extname(file));
        this.endpoints.set(name, endpoint);
      }
    });

    // Analyze client usage
    [...componentFiles, ...libFiles].forEach(file => {
      const usage = this.analyzeClientUsage(file);
      if (usage && usage.endpoints.length > 0) {
        const name = path.relative(process.cwd(), file);
        this.clients.set(name, usage);
      }
    });

    // Extract common patterns
    this.extractCommonPatterns();

    return this.buildReport();
  }

  /**
   * Extract common API patterns
   */
  extractCommonPatterns() {
    // Pattern 1: CRUD operations
    const crudEndpoints = Array.from(this.endpoints.values())
      .filter(ep => ['GET', 'POST', 'PUT', 'DELETE'].includes(ep.method));

    if (crudEndpoints.length > 0) {
      this.patterns.push({
        name: 'RESTful CRUD Pattern',
        description: 'Standard Create, Read, Update, Delete operations',
        endpoints: crudEndpoints.length,
        example: 'GET /api/items, POST /api/items, PUT /api/items/[id], DELETE /api/items/[id]'
      });
    }

    // Pattern 2: File upload handling
    const uploadEndpoints = Array.from(this.endpoints.values())
      .filter(ep => ep.operations.some(op => op.type === 'storage'));

    if (uploadEndpoints.length > 0) {
      this.patterns.push({
        name: 'File Upload Pattern',
        description: 'File upload with compression and storage',
        endpoints: uploadEndpoints.length,
        steps: [
          'Receive multipart/form-data',
          'Validate file type and size',
          'Compress image if needed',
          'Upload to Supabase Storage',
          'Return public URL'
        ]
      });
    }

    // Pattern 3: Async processing with status updates
    const asyncEndpoints = Array.from(this.endpoints.values())
      .filter(ep => ep.operations.some(op => op.type === 'async_dependency'));

    if (asyncEndpoints.length > 0) {
      this.patterns.push({
        name: 'Async Processing Pattern',
        description: 'Long-running operations with status tracking',
        endpoints: asyncEndpoints.length,
        example: 'Batch generation, AI image processing'
      });
    }
  }

  /**
   * Build comprehensive API pattern report
   */
  buildReport() {
    return {
      summary: {
        totalEndpoints: this.endpoints.size,
        totalClients: this.clients.size,
        totalPatterns: this.patterns.length
      },
      endpoints: Object.fromEntries(this.endpoints),
      clients: Object.fromEntries(this.clients),
      patterns: this.patterns,
      recommendations: this.generateRecommendations()
    };
  }

  /**
   * Generate recommendations based on analysis
   */
  generateRecommendations() {
    const recommendations = [];

    // Check for consistent error handling
    let hasErrorHandling = 0;
    this.clients.forEach(usage => {
      if (usage.errorHandling.length > 0) hasErrorHandling++;
    });

    if (hasErrorHandling < this.clients.size * 0.8) {
      recommendations.push({
        type: 'error_handling',
        priority: 'high',
        message: 'Consider adding consistent error handling to all API calls'
      });
    }

    // Check for authentication patterns
    const authEndpoints = Array.from(this.endpoints.values())
      .filter(ep => ep.parameters.some(p =>
        p.properties.some(prop => prop.name === 'user' || prop.name === 'auth')
      ));

    if (authEndpoints.length > 0 && authEndpoints.length < this.endpoints.size) {
      recommendations.push({
        type: 'authentication',
        priority: 'medium',
        message: 'Some endpoints may need authentication checks'
      });
    }

    // Check for response standardization
    const responseTypes = new Set();
    this.endpoints.forEach(ep => {
      ep.responses.forEach(res => {
        responseTypes.add(res.type);
      });
    });

    if (responseTypes.size > 3) {
      recommendations.push({
        type: 'response_standardization',
        priority: 'low',
        message: 'Consider standardizing API response formats'
      });
    }

    return recommendations;
  }

  /**
   * Generate markdown report
   */
  generateMarkdownReport(report) {
    let markdown = '# API Pattern Analysis Report\n\n';
    markdown += `Generated on: ${new Date().toISOString()}\n\n`;

    // Summary
    markdown += '## Summary\n\n';
    markdown += `- **Total Endpoints**: ${report.summary.totalEndpoints}\n`;
    markdown += `- **Total Clients**: ${report.summary.totalClients}\n`;
    markdown += `- **Patterns Identified**: ${report.summary.totalPatterns}\n\n`;

    // Common Patterns
    markdown += '## Common API Patterns\n\n';
    report.patterns.forEach(pattern => {
      markdown += `### ${pattern.name}\n`;
      markdown += `${pattern.description}\n\n`;
      if (pattern.endpoints) {
        markdown += `- **Endpoints using this pattern**: ${pattern.endpoints}\n`;
      }
      if (pattern.example) {
        markdown += `- **Example**: ${pattern.example}\n`;
      }
      if (pattern.steps) {
        markdown += '**Steps**:\n';
        pattern.steps.forEach((step, i) => {
          markdown += `${i + 1}. ${step}\n`;
        });
      }
      markdown += '\n';
    });

    // Recommendations
    if (report.recommendations.length > 0) {
      markdown += '## Recommendations\n\n';
      report.recommendations.forEach(rec => {
        const priority = rec.priority === 'high' ? '🔴' :
                        rec.priority === 'medium' ? '🟡' : '🟢';
        markdown += `### ${priority} ${rec.type.replace('_', ' ')}\n`;
        markdown += `${rec.message}\n\n`;
      });
    }

    return markdown;
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const analyzer = new APIPatternAnalyzer();
  const report = analyzer.analyzeAll();

  console.log('Analyzing API patterns...');

  const outputDir = '.claude/generated';
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const reportPath = path.join(outputDir, 'api-pattern-report.md');
  const markdown = analyzer.generateMarkdownReport(report);

  fs.writeFileSync(reportPath, markdown);
  console.log(`API pattern report generated: ${reportPath}`);

  // Also output JSON for programmatic use
  const jsonPath = path.join(outputDir, 'api-pattern-analysis.json');
  fs.writeFileSync(jsonPath, JSON.stringify(report, null, 2));
  console.log(`JSON analysis saved: ${jsonPath}`);
}

export default APIPatternAnalyzer;