#!/usr/bin/env node

/**
 * TypeScript AST Analyzer
 *
 * This script analyzes TypeScript files to extract:
 * - Interface definitions
 * - Component Props
 * - Dependencies (import/export)
 * - Type definitions
 */

import { parse } from '@typescript-eslint/parser';
import { TSESTree } from '@typescript-eslint/typescript-estree';
import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

class TypeScriptAnalyzer {
  constructor() {
    this.interfaces = new Map();
    this.components = new Map();
    this.dependencies = new Map();
    this.types = new Map();
    this.exports = new Map();
    this.imports = new Map();
  }

  /**
   * Parse a TypeScript file and return AST
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
   * Extract interface definitions from AST
   */
  extractInterfaces(ast, filePath) {
    const interfaces = [];

    TSESTree.simpleTraverse(ast, {
      TSInterfaceDeclaration(node) {
        const interfaceInfo = {
          name: node.id.name,
          properties: [],
          extends: [],
          generics: [],
          isExported: false,
          location: {
            line: node.loc.start.line,
            column: node.loc.start.column
          }
        };

        // Extract generic type parameters
        if (node.typeParameters) {
          interfaceInfo.generics = node.typeParameters.params.map(param => ({
            name: param.name.name,
            constraint: param.constraint ? this.getTypeString(param.constraint) : null,
            default: param.default ? this.getTypeString(param.default) : null
          }));
        }

        // Extract extended interfaces
        if (node.extends) {
          interfaceInfo.extends = node.extends.map(ext => ({
            name: ext.expression.name,
            typeArgs: ext.typeParameters ? ext.typeParameters.params.map(p => this.getTypeString(p)) : []
          }));
        }

        // Extract properties
        node.body.body.forEach(member => {
          if (member.type === 'TSPropertySignature') {
            interfaceInfo.properties.push({
              name: member.key.name,
              type: this.getTypeString(member.typeAnnotation),
              optional: member.optional,
              readonly: member.readonly,
              location: {
                line: member.loc.start.line,
                column: member.loc.start.column
              }
            });
          }
        });

        interfaces.push(interfaceInfo);
      }
    });

    // Check if interfaces are exported
    TSESTree.simpleTraverse(ast, {
      ExportNamedDeclaration(node) {
        if (node.declaration && node.declaration.type === 'TSInterfaceDeclaration') {
          const exportedInterface = interfaces.find(i => i.name === node.declaration.id.name);
          if (exportedInterface) {
            exportedInterface.isExported = true;
          }
        }
      },
      ExportDefaultDeclaration(node) {
        if (node.declaration && node.declaration.type === 'TSInterfaceDeclaration') {
          const exportedInterface = interfaces.find(i => i.name === node.declaration.id.name);
          if (exportedInterface) {
            exportedInterface.isExported = true;
          }
        }
      }
    });

    return interfaces;
  }

  /**
   * Analyze React component props
   */
  analyzeComponentProps(ast, filePath) {
    const components = [];

    TSESTree.simpleTraverse(ast, {
      FunctionDeclaration(node) {
        // Check if this is a React component function
        if (this.isReactComponent(node)) {
          components.push(this.analyzeFunctionComponent(node, filePath));
        }
      },
      FunctionExpression(node) {
        if (this.isReactComponent(node)) {
          components.push(this.analyzeFunctionComponent(node, filePath));
        }
      },
      ArrowFunctionExpression(node) {
        if (this.isReactComponent(node)) {
          components.push(this.analyzeFunctionComponent(node, filePath));
        }
      },
      VariableDeclarator(node) {
        if (node.init && (node.init.type === 'ArrowFunctionExpression' || node.init.type === 'FunctionExpression')) {
          if (this.isReactComponent(node.init)) {
            components.push(this.analyzeFunctionComponent(node.init, filePath, node.id.name));
          }
        }
      }
    });

    return components;
  }

  /**
   * Check if a node represents a React component
   */
  isReactComponent(node) {
    // Check if it returns JSX
    let returnsJSX = false;

    TSESTree.simpleTraverse(node, {
      ReturnStatement(returnNode) {
        if (returnNode.argument &&
            (returnNode.argument.type === 'JSXElement' ||
             returnNode.argument.type === 'JSXFragment')) {
          returnsJSX = true;
        }
      }
    });

    return returnsJSX;
  }

  /**
   * Analyze a function component
   */
  analyzeFunctionComponent(node, filePath, name = null) {
    const component = {
      name: name || this.extractComponentName(node, filePath),
      props: {},
      hooks: [],
      state: [],
      effects: [],
      location: {
        line: node.loc.start.line,
        column: node.loc.start.column
      }
    };

    // Extract props from first parameter
    if (node.params && node.params[0]) {
      const propsParam = node.params[0];
      if (propsParam.type === 'ObjectPattern') {
        component.props = this.extractDestructuredProps(propsParam);
      } else if (propsParam.typeIdentifier) {
        component.props.type = this.getTypeString(propsParam.typeAnnotation);
        component.props.name = propsParam.typeIdentifier.typeAnnotation
          ? this.getTypeString(propsParam.typeAnnotation.typeAnnotation)
          : 'any';
      }
    }

    // Find hooks usage
    TSESTree.simpleTraverse(node, {
      CallExpression(callNode) {
        const callee = callNode.callee;
        if (callee.type === 'Identifier') {
          if (callee.name.startsWith('use')) {
            component.hooks.push({
              name: callee.name,
              line: callNode.loc.start.line
            });
          }
        } else if (callee.type === 'MemberExpression' &&
                   callee.object &&
                   callee.object.type === 'Identifier' &&
                   callee.object.name === 'React' &&
                   callee.property &&
                   callee.property.type === 'Identifier' &&
                   callee.property.name.startsWith('use')) {
          component.hooks.push({
            name: `React.${callee.property.name}`,
            line: callNode.loc.start.line
          });
        }
      }
    });

    return component;
  }

  /**
   * Extract destructured props
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
   * Build dependency graph
   */
  buildDependencyGraph(ast, filePath) {
    const dependencies = {
      imports: [],
      exports: []
    };

    TSESTree.simpleTraverse(ast, {
      ImportDeclaration(node) {
        const importInfo = {
          source: node.source.value,
          specifiers: [],
          isTypeOnly: node.importKind === 'type'
        };

        node.specifiers.forEach(spec => {
          if (spec.type === 'ImportDefaultSpecifier') {
            importInfo.specifiers.push({
              type: 'default',
              local: spec.local.name
            });
          } else if (spec.type === 'ImportSpecifier') {
            importInfo.specifiers.push({
              type: 'named',
              imported: spec.imported.name,
              local: spec.local.name,
              isType: spec.importKind === 'type'
            });
          } else if (spec.type === 'ImportNamespaceSpecifier') {
            importInfo.specifiers.push({
              type: 'namespace',
              local: spec.local.name
            });
          }
        });

        dependencies.imports.push(importInfo);
      },
      ExportNamedDeclaration(node) {
        const exportInfo = {
          specifiers: [],
          source: node.source ? node.source.value : null
        };

        if (node.declaration) {
          if (node.declaration.type === 'VariableDeclaration') {
            node.declaration.declarations.forEach(decl => {
              exportInfo.specifiers.push({
                type: 'variable',
                name: decl.id.name
              });
            });
          } else if (node.declaration.type === 'FunctionDeclaration' && node.declaration.id) {
            exportInfo.specifiers.push({
              type: 'function',
              name: node.declaration.id.name
            });
          } else if (node.declaration.type === 'TSInterfaceDeclaration') {
            exportInfo.specifiers.push({
              type: 'interface',
              name: node.declaration.id.name
            });
          }
        }

        if (node.specifiers) {
          node.specifiers.forEach(spec => {
            exportInfo.specifiers.push({
              type: 'specifier',
              local: spec.local.name,
              exported: spec.exported.name
            });
          });
        }

        dependencies.exports.push(exportInfo);
      },
      ExportDefaultDeclaration(node) {
        let name = null;
        if (node.declaration.type === 'Identifier') {
          name = node.declaration.name;
        } else if (node.declaration.id) {
          name = node.declaration.id.name;
        }

        dependencies.exports.push({
          type: 'default',
          name: name,
          anonymous: !name
        });
      }
    });

    return dependencies;
  }

  /**
   * Extract exports from AST
   */
  extractExports(ast) {
    const exports = [];

    TSESTree.simpleTraverse(ast, {
      ExportNamedDeclaration(node) {
        if (node.declaration) {
          if (node.declaration.type === 'VariableDeclaration') {
            node.declaration.declarations.forEach(decl => {
              exports.push({
                name: decl.id.name,
                type: 'variable',
                isDefault: false
              });
            });
          } else if (node.declaration.type === 'FunctionDeclaration' && node.declaration.id) {
            exports.push({
              name: node.declaration.id.name,
              type: 'function',
              isDefault: false
            });
          } else if (node.declaration.type === 'TSInterfaceDeclaration') {
            exports.push({
              name: node.declaration.id.name,
              type: 'interface',
              isDefault: false
            });
          }
        }
      },
      ExportDefaultDeclaration(node) {
        let name = 'default';
        if (node.declaration) {
          if (node.declaration.type === 'Identifier') {
            name = node.declaration.name;
          } else if (node.declaration.id) {
            name = node.declaration.id.name;
          }
        }
        exports.push({
          name: name,
          type: 'default',
          isDefault: true
        });
      }
    });

    return exports;
  }

  /**
   * Extract imports from AST
   */
  extractImports(ast) {
    const imports = [];

    TSESTree.simpleTraverse(ast, {
      ImportDeclaration(node) {
        imports.push({
          source: node.source.value,
          specifiers: node.specifiers.map(spec => ({
            name: spec.local.name,
            imported: spec.imported ? spec.imported.name : null,
            isDefault: spec.type === 'ImportDefaultSpecifier',
            isType: spec.importKind === 'type'
          }))
        });
      }
    });

    return imports;
  }

  /**
   * Convert AST type node to string
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
      case 'TSVoidKeyword':
        return 'void';
      case 'TSAnyKeyword':
        return 'any';
      case 'TSUnknownKeyword':
        return 'unknown';
      case 'TSArrayType':
        return `${this.getTypeString(typeNode.elementType)}[]`;
      case 'TSUnionType':
        return typeNode.types.map(t => this.getTypeString(t)).join(' | ');
      case 'TSIntersectionType':
        return typeNode.types.map(t => this.getTypeString(t)).join(' & ');
      case 'TSTypeReference':
        let name = typeNode.typeName.name;
        if (typeNode.typeParameters) {
          const params = typeNode.typeParameters.params.map(p => this.getTypeString(p));
          name += `<${params.join(', ')}>`;
        }
        return name;
      case 'TSFunctionType':
        const params = typeNode.parameters.map(p => `${p.name}: ${this.getTypeString(p.typeAnnotation)}`);
        const returnType = typeNode.returnType ? this.getTypeString(typeNode.returnType) : 'void';
        return `(${params.join(', ')}) => ${returnType}`;
      case 'TSObjectKeyword':
        return 'object';
      case 'TSNullKeyword':
        return 'null';
      case 'TSUndefinedKeyword':
        return 'undefined';
      case 'TSLiteralType':
        return JSON.stringify(typeNode.literal.value);
      default:
        return 'any';
    }
  }

  /**
   * Extract component name from file path or node
   */
  extractComponentName(node, filePath) {
    // Try to get name from function declaration
    if (node.id && node.id.name) {
      return node.id.name;
    }

    // Extract from filename
    const fileName = path.basename(filePath, path.extname(filePath));
    return fileName;
  }

  /**
   * Analyze a single file
   */
  analyzeFile(filePath) {
    const ast = this.parseFile(filePath);
    if (!ast) return null;

    return {
      filePath,
      interfaces: this.extractInterfaces(ast, filePath),
      components: this.analyzeComponentProps(ast, filePath),
      dependencies: this.buildDependencyGraph(ast, filePath),
      exports: this.extractExports(ast),
      imports: this.extractImports(ast)
    };
  }

  /**
   * Analyze multiple files
   */
  analyzeFiles(pattern) {
    const files = glob.sync(pattern, {
      cwd: process.cwd(),
      absolute: true
    });

    const results = [];

    for (const file of files) {
      const analysis = this.analyzeFile(file);
      if (analysis) {
        results.push(analysis);
      }
    }

    return results;
  }

  /**
   * Generate analysis summary
   */
  generateSummary(analyses) {
    const summary = {
      totalFiles: analyses.length,
      totalInterfaces: 0,
      totalComponents: 0,
      interfaces: [],
      components: [],
      dependencyGraph: {}
    };

    // Collect all interfaces
    analyses.forEach(analysis => {
      summary.totalInterfaces += analysis.interfaces.length;
      summary.interfaces.push(...analysis.interfaces.map(intf => ({
        ...intf,
        file: analysis.filePath
      })));
    });

    // Collect all components
    analyses.forEach(analysis => {
      summary.totalComponents += analysis.components.length;
      summary.components.push(...analysis.components.map(comp => ({
        ...comp,
        file: analysis.filePath
      })));
    });

    // Build dependency graph
    analyses.forEach(analysis => {
      const relativePath = path.relative(process.cwd(), analysis.filePath);
      summary.dependencyGraph[relativePath] = {
        imports: analysis.imports.map(imp => imp.source),
        exported: analysis.exports.map(exp => exp.name)
      };
    });

    return summary;
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  import { Command } from 'commander';
  import chalk from 'chalk';
  import ora from 'ora';
  import TypeScriptAnalyzer from './analyze-typescript.mjs';

  const program = new Command();

  program
    .name('analyze-typescript')
    .description('Analyze TypeScript files for LLM context generation')
    .option('-p, --pattern <pattern>', 'Glob pattern for files to analyze', '**/*.{ts,tsx}')
    .option('-o, --output <file>', 'Output file for analysis results')
    .option('-f, --format <format>', 'Output format (json|markdown)', 'json')
    .option('-s, --summary', 'Show summary only')
    .parse();

  const options = program.opts();

  const spinner = ora('Analyzing TypeScript files...').start();

  const analyzer = new TypeScriptAnalyzer();
  const analyses = analyzer.analyzeFiles(options.pattern);

  spinner.succeed(`Analyzed ${analyses.length} files`);

  if (options.summary) {
    const summary = analyzer.generateSummary(analyses);

    if (options.format === 'markdown') {
      console.log(chalk.blue('\n## Analysis Summary\n'));
      console.log(`- **Total Files**: ${summary.totalFiles}`);
      console.log(`- **Total Interfaces**: ${summary.totalInterfaces}`);
      console.log(`- **Total Components**: ${summary.totalComponents}`);

      console.log(chalk.blue('\n### Interfaces\n'));
      summary.interfaces.forEach(intf => {
        const relPath = path.relative(process.cwd(), intf.file);
        console.log(`- **${intf.name}** (${relPath}:${intf.location.line})`);
      });

      console.log(chalk.blue('\n### Components\n'));
      summary.components.forEach(comp => {
        const relPath = path.relative(process.cwd(), comp.file);
        console.log(`- **${comp.name}** (${relPath}:${comp.location.line})`);
      });
    } else {
      console.log(JSON.stringify(summary, null, 2));
    }
  } else {
    if (options.output) {
      fs.writeFileSync(options.output, JSON.stringify(analyses, null, 2));
      console.log(chalk.green(`Results saved to ${options.output}`));
    } else {
      console.log(JSON.stringify(analyses, null, 2));
    }
  }
}

export default TypeScriptAnalyzer;