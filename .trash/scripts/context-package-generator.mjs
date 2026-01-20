#!/usr/bin/env node

/**
 * Context Package Generator
 *
 * This script generates context packages for LLM to quickly understand
 * specific features or modules in the codebase.
 */

import { parse } from '@typescript-eslint/parser';
import { TSESTree } from '@typescript-eslint/typescript-estree';
import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

class ContextPackageGenerator {
  constructor() {
    this.packages = new Map();
    this.fileMap = new Map();
    this.typeMap = new Map();
    this.componentMap = new Map();
    this.apiMap = new Map();
    this.hookMap = new Map();
  }

  /**
   * Find files related to a specific feature
   */
  findRelatedFiles(feature, rootDir = process.cwd()) {
    const relatedFiles = {
      components: [],
      apis: [],
      types: [],
      hooks: [],
      utils: [],
      pages: []
    };

    // Feature to file patterns mapping
    const featurePatterns = {
      character: {
        components: [
          '**/Character*.{ts,tsx}',
          '**/*[Cc]haracter*.{ts,tsx}'
        ],
        apis: [
          'pages/api/characters/**/*.{ts,tsx}',
          'pages/api/images/character*.{ts,tsx}'
        ],
        types: [
          'types/*[Cc]haracter*.{ts,tsx}'
        ],
        hooks: [
          'lib/hooks/*[Cc]haracter*.{ts,tsx}'
        ]
      },
      batch: {
        components: [
          '**/Batch*.{ts,tsx}',
          '**/*[Bb]atch*.{ts,tsx}'
        ],
        apis: [
          'pages/api/batch/**/*.{ts,tsx}'
        ],
        types: [
          'types/*[Bb]atch*.{ts,tsx}'
        ],
        utils: [
          'lib/batch/**/*.{ts,tsx}'
        ],
        hooks: [
          'lib/hooks/*[Bb]atch*.{ts,tsx}'
        ]
      },
      book: {
        components: [
          '**/Book*.{ts,tsx}',
          '**/*[Bb]ook*.{ts,tsx}'
        ],
        apis: [
          'pages/api/books/**/*.{ts,tsx}'
        ],
        pages: [
          'pages/books/**/*.{tsx}'
        ],
        types: [
          'types/*[Bb]ook*.{ts,tsx}'
        ],
        hooks: [
          'lib/hooks/*[Bb]ook*.{ts,tsx}'
        ]
      },
      image: {
        components: [
          '**/Image*.{ts,tsx}',
          '**/*[Ii]mage*.{ts,tsx}'
        ],
        apis: [
          'pages/api/images/**/*.{ts,tsx}'
        ],
        utils: [
          'lib/**/*[Ii]mage*.{ts,tsx}'
        ]
      },
      text: {
        components: [
          '**/Text*.{ts,tsx}',
          '**/*[Tt]ext*.{ts,tsx}'
        ],
        apis: [
          'pages/api/**/*[Tt]ext*.{ts,tsx}'
        ]
      }
    };

    // Use pattern based on feature name
    const patterns = featurePatterns[feature.toLowerCase()] || this.generateGenericPatterns(feature);

    // Find files matching patterns
    Object.entries(patterns).forEach(([category, patternList]) => {
      patternList.forEach(pattern => {
        const files = glob.sync(pattern, { cwd: rootDir, absolute: true });
        relatedFiles[category].push(...files);
      });
    });

    // Remove duplicates
    Object.keys(relatedFiles).forEach(category => {
      relatedFiles[category] = [...new Set(relatedFiles[category])];
    });

    return relatedFiles;
  }

  /**
   * Generate generic patterns for feature
   */
  generateGenericPatterns(feature) {
    const featureLower = feature.toLowerCase();
    const featureUpper = feature.charAt(0).toUpperCase() + feature.slice(1);

    return {
      components: [
        `**/${featureUpper}*.{ts,tsx}`,
        `**/*${featureLower}*.{ts,tsx}`
      ],
      apis: [
        `pages/api/${featureLower}/**/*.{ts,tsx}`
      ],
      types: [
        `types/*${featureLower}*.{ts,tsx}`
      ],
      hooks: [
        `lib/hooks/*${featureLower}*.{ts,tsx}`
      ]
    };
  }

  /**
   * Extract type definitions from files
   */
  extractTypes(files) {
    const types = new Map();

    files.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf-8');
        const ast = parse(content, {
          sourceType: 'module',
          ecmaVersion: 2020,
          ecmaFeatures: {
            jsx: true
          }
        });

        // Extract interfaces and types
        TSESTree.simpleTraverse(ast, {
          TSInterfaceDeclaration(node) {
            const interfaceInfo = {
              name: node.id.name,
              file: path.relative(process.cwd(), file),
              location: node.loc.start,
              properties: []
            };

            // Extract properties
            node.body.body.forEach(member => {
              if (member.type === 'TSPropertySignature') {
                interfaceInfo.properties.push({
                  name: member.key.name,
                  type: this.getTypeString(member.typeAnnotation),
                  optional: member.optional
                });
              }
            });

            types.set(interfaceInfo.name, interfaceInfo);
          },
          TSTypeAliasDeclaration(node) {
            const typeInfo = {
              name: node.id.name,
              file: path.relative(process.cwd(), file),
              location: node.loc.start,
              type: this.getTypeString(node.typeAnnotation)
            };

            types.set(typeInfo.name, typeInfo);
          }
        });
      } catch (error) {
        console.error(`Error parsing ${file}:`, error.message);
      }
    });

    return types;
  }

  /**
   * Extract components with props
   */
  extractComponents(files) {
    const components = new Map();

    files.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf-8');
        const ast = parse(content, {
          sourceType: 'module',
          ecmaVersion: 2020,
          ecmaFeatures: {
            jsx: true
          }
        });

        // Find React components
        TSESTree.simpleTraverse(ast, {
          FunctionDeclaration(node) {
            if (this.isReactComponent(node) && node.id) {
              components.set(node.id.name, {
                name: node.id.name,
                file: path.relative(process.cwd(), file),
                props: this.extractComponentProps(node),
                hooks: this.extractHooksFromNode(node)
              });
            }
          },
          VariableDeclarator(node) {
            if (node.init && this.isReactComponent(node.init) && node.id) {
              components.set(node.id.name, {
                name: node.id.name,
                file: path.relative(process.cwd(), file),
                props: this.extractComponentProps(node.init),
                hooks: this.extractHooksFromNode(node.init)
              });
            }
          }
        });
      } catch (error) {
        console.error(`Error parsing ${file}:`, error.message);
      }
    });

    return components;
  }

  /**
   * Extract API endpoints from files
   */
  extractAPIs(files) {
    const apis = new Map();

    files.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf-8');
        const ast = parse(content, {
          sourceType: 'module',
          ecmaVersion: 2020
        });

        // Find API routes
        TSESTree.simpleTraverse(ast, {
          ExportNamedDeclaration(node) {
            if (node.declaration && node.declaration.type === 'FunctionDeclaration') {
              const routePath = this.extractRoutePath(file);
              if (routePath) {
                apis.set(routePath, {
                  path: routePath,
                  method: this.extractHTTPMethod(node.declaration),
                  file: path.relative(process.cwd(), file),
                  input: this.extractAPISchema(node.declaration, 'input'),
                  output: this.extractAPISchema(node.declaration, 'output')
                });
              }
            }
          }
        });
      } catch (error) {
        console.error(`Error parsing ${file}:`, error.message);
      }
    });

    return apis;
  }

  /**
   * Extract hooks from files
   */
  extractHooks(files) {
    const hooks = new Map();

    files.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf-8');
        const ast = parse(content, {
          sourceType: 'module',
          ecmaVersion: 2020
        });

        TSESTree.simpleTraverse(ast, {
          ExportNamedDeclaration(node) {
            if (node.declaration && node.declaration.type === 'FunctionDeclaration') {
              const name = node.declaration.id.name;
              if (name.startsWith('use')) {
                hooks.set(name, {
                  name,
                  file: path.relative(process.cwd(), file),
                  params: node.declaration.params.map(p => p.name),
                  returnType: this.extractReturnType(node.declaration)
                });
              }
            }
          },
          VariableDeclarator(node) {
            if (node.init && node.init.type === 'ArrowFunctionExpression' && node.id) {
              const name = node.id.name;
              if (name.startsWith('use')) {
                hooks.set(name, {
                  name,
                  file: path.relative(process.cwd(), file),
                  params: node.init.params.map(p => p.name),
                  returnType: this.extractReturnType(node.init)
                });
              }
            }
          }
        });
      } catch (error) {
        console.error(`Error parsing ${file}:`, error.message);
      }
    });

    return hooks;
  }

  /**
   * Generate context package for feature
   */
  generateContextPackage(feature, relatedFiles) {
    const packageContent = {
      feature,
      timestamp: new Date().toISOString(),
      types: {},
      components: {},
      apis: {},
      hooks: {},
      patterns: [],
      examples: []
    };

    // Extract information from related files
    if (relatedFiles.types.length > 0) {
      packageContent.types = Object.fromEntries(this.extractTypes(relatedFiles.types));
    }

    if (relatedFiles.components.length > 0) {
      packageContent.components = Object.fromEntries(this.extractComponents(relatedFiles.components));
    }

    if (relatedFiles.apis.length > 0) {
      packageContent.apis = Object.fromEntries(this.extractAPIs(relatedFiles.apis));
    }

    if (relatedFiles.hooks.length > 0) {
      packageContent.hooks = Object.fromEntries(this.extractHooks(relatedFiles.hooks));
    }

    // Extract common patterns
    packageContent.patterns = this.extractCommonPatterns(packageContent);

    // Generate usage examples
    packageContent.examples = this.generateExamples(feature, packageContent);

    return packageContent;
  }

  /**
   * Extract common usage patterns
   */
  extractCommonPatterns(packageContent) {
    const patterns = [];

    // Analyze component usage
    Object.values(packageContent.components).forEach(comp => {
      if (comp.hooks.includes('useState')) {
        patterns.push(`${comp.name} uses local state management`);
      }
      if (comp.hooks.includes('useEffect')) {
        patterns.push(`${comp.name} has side effects that need cleanup`);
      }
    });

    // Analyze API usage
    Object.values(packageContent.apis).forEach(api => {
      patterns.push(`${api.method} ${api.path} - ${api.method === 'GET' ? 'Data retrieval' : 'Data modification'}`);
    });

    // Analyze hook usage
    Object.values(packageContent.hooks).forEach(hook => {
      if (hook.name.includes('List') || hook.name.includes('All')) {
        patterns.push(`${hook.name} - Fetches collection of data`);
      }
      if (hook.name.includes('Create') || hook.name.includes('Add')) {
        patterns.push(`${hook.name} - Creates new resource`);
      }
    });

    return patterns;
  }

  /**
   * Generate usage examples
   */
  generateExamples(feature, packageContent) {
    const examples = [];

    // Component usage example
    const componentExample = this.generateComponentExample(packageContent);
    if (componentExample) {
      examples.push(componentExample);
    }

    // Hook usage example
    const hookExample = this.generateHookExample(packageContent);
    if (hookExample) {
      examples.push(hookExample);
    }

    // API usage example
    const apiExample = this.generateAPIExample(packageContent);
    if (apiExample) {
      examples.push(apiExample);
    }

    return examples;
  }

  /**
   * Generate component usage example
   */
  generateComponentExample(packageContent) {
    const components = Object.values(packageContent.components);
    if (components.length === 0) return null;

    const comp = components[0];
    const props = Object.entries(comp.props || {})
      .map(([name, info]) => `${name}: ${info.type}`)
      .join(', ');

    return {
      title: `${comp.name} Component Usage`,
      code: `<${comp.name} ${props ? `{${props}}` : ''} />`
    };
  }

  /**
   * Generate hook usage example
   */
  generateHookExample(packageContent) {
    const hooks = Object.values(packageContent.hooks);
    if (hooks.length === 0) return null;

    const hook = hooks[0];
    const params = hook.params.join(', ');

    return {
      title: `${hook.name} Hook Usage`,
      code: `const ${hook.params.length > 1 ? '[...result]' : 'result'} = ${hook.name}(${params});`
    };
  }

  /**
   * Generate API usage example
   */
  generateAPIExample(packageContent) {
    const apis = Object.values(packageContent.apis);
    if (apis.length === 0) return null;

    const api = apis[0];
    const body = api.input ? JSON.stringify(api.input, null, 2) : '{}';

    const apiCode = `fetch('${api.path}', {
  method: '${api.method.toLowerCase()}',
  headers: {
    'Content-Type': 'application/json',
  },
  body: ${body}
})`;

    return {
      title: `${api.method} ${api.path} API Usage`,
      code: apiCode
    };
  }

  /**
   * Render context package as markdown
   */
  renderContextPackage(packageContent) {
    let markdown = `# ${packageContent.feature} Context Package\n\n`;
    markdown += `*Generated on ${packageContent.timestamp}*\n\n`;

    // Type Definitions
    if (Object.keys(packageContent.types).length > 0) {
      markdown += `## Type Definitions\n\n`;
      Object.entries(packageContent.types).forEach(([name, type]) => {
        markdown += `### ${name}\n`;
        markdown += `**File**: \`${type.file}\`\n\n`;

        if (type.properties && type.properties.length > 0) {
          markdown += `**Properties**:\n`;
          type.properties.forEach(prop => {
            markdown += `- \`${prop.name}\`${prop.optional ? ' (optional)' : ''}: ${prop.type}\n`;
          });
          markdown += '\n';
        }
      });
      markdown += '\n';
    }

    // Components
    if (Object.keys(packageContent.components).length > 0) {
      markdown += `## Components\n\n`;
      Object.entries(packageContent.components).forEach(([name, comp]) => {
        markdown += `### ${name}\n`;
        markdown += `**File**: \`${comp.file}\`\n\n`;

        if (Object.keys(comp.props || {}).length > 0) {
          markdown += `**Props**:\n`;
          Object.entries(comp.props).forEach(([propName, propInfo]) => {
            markdown += `- \`${propName}\`: ${propInfo.type}\n`;
          });
          markdown += '\n';
        }
      });
      markdown += '\n';
    }

    // API Endpoints
    if (Object.keys(packageContent.apis).length > 0) {
      markdown += `## API Endpoints\n\n`;
      Object.entries(packageContent.apis).forEach(([path, api]) => {
        markdown += `### ${api.method} ${path}\n`;
        markdown += `**File**: \`${api.file}\`\n\n`;

        if (api.input) {
          markdown += `**Input**:\n\`\`\`json\n${JSON.stringify(api.input, null, 2)}\n\`\`\n\n`;
        }

        if (api.output) {
          markdown += `**Output**:\n\`\`\`json\n${JSON.stringify(api.output, null, 2)}\n\`\`\n\n`;
        }
      });
      markdown += '\n';
    }

    // Hooks
    if (Object.keys(packageContent.hooks).length > 0) {
      markdown += `## Hooks\n\n`;
      Object.entries(packageContent.hooks).forEach(([name, hook]) => {
        markdown += `### ${name}\n`;
        markdown += `**File**: \`${hook.file}\`\n\n`;
        markdown += `**Parameters**: ${hook.params.join(', ')}\n\n`;
      });
      markdown += '\n';
    }

    // Common Patterns
    if (packageContent.patterns.length > 0) {
      markdown += `## Common Patterns\n\n`;
      packageContent.patterns.forEach(pattern => {
        markdown += `- ${pattern}\n`;
      });
      markdown += '\n';
    }

    // Usage Examples
    if (packageContent.examples.length > 0) {
      markdown += `## Usage Examples\n\n`;
      packageContent.examples.forEach(example => {
        markdown += `### ${example.title}\n`;
        markdown += `\`\`\`${this.detectLanguage(example.code)}\n${example.code}\n\`\`\n\n`;
      });
    }

    return markdown;
  }

  /**
   * Detect programming language for syntax highlighting
   */
  detectLanguage(code) {
    if (code.includes('<') && code.includes('>') && code.includes('/>')) {
      return 'jsx';
    }
    if (code.includes('fetch') || code.includes('async')) {
      return 'javascript';
    }
    if (code.includes('interface') || code.includes('type')) {
      return 'typescript';
    }
    return '';
  }

  /**
   * Helper methods
   */
  isReactComponent(node) {
    // Simplified check - in production, use the full implementation from component-analyzer
    return node.type === 'FunctionDeclaration' || node.type === 'ArrowFunctionExpression';
  }

  extractComponentProps(node) {
    // Simplified - extract basic props info
    return {};
  }

  extractHooksFromNode(node) {
    // Simplified - return empty array
    return [];
  }

  extractRoutePath(filePath) {
    // Extract route from file path
    const match = filePath.match(/pages\/api\/(.+)\.ts/);
    return match ? match[1].replace(/\[.*?\]/g, ':id') : null;
  }

  extractHTTPMethod(node) {
    // Extract HTTP method from function name or annotations
    const name = node.id ? node.id.name : '';
    if (name.includes('get') || name.includes('Get')) return 'GET';
    if (name.includes('post') || name.includes('Create')) return 'POST';
    if (name.includes('put') || name.includes('Update')) return 'PUT';
    if (name.includes('delete') || name.includes('Delete')) return 'DELETE';
    return 'GET';
  }

  extractAPISchema(node, type) {
    // Simplified schema extraction
    return {
      type: 'object',
      properties: {}
    };
  }

  extractReturnType(node) {
    // Simplified return type extraction
    return 'any';
  }

  getTypeString(typeNode) {
    // Simplified type string extraction
    if (!typeNode) return 'any';
    if (typeNode.typeName) {
      return typeNode.typeName.name;
    }
    return 'any';
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  import { Command } from 'commander';
  import chalk from 'chalk';
  import ora from 'ora';

  const program = new Command();

  program
    .name('context-package-generator')
    .description('Generate context packages for LLM')
    .option('-f, --feature <feature>', 'Feature name (character, batch, book, image, text)')
    .option('-o, --output <dir>', 'Output directory', '.claude/context-packages')
    .option('--list', 'List available features')
    .parse();

  const options = program.opts();

  if (options.list) {
    console.log(chalk.blue('Available features:'));
    console.log('- character');
    console.log('- batch');
    console.log('- book');
    console.log('- image');
    console.log('- text');
    console.log('\nYou can also provide any custom feature name.');
    process.exit(0);
  }

  if (!options.feature) {
    console.error(chalk.red('Error: Feature name is required. Use -f <feature>'));
    process.exit(1);
  }

  const spinner = ora('Generating context package...').start();

  const generator = new ContextPackageGenerator();
  const relatedFiles = generator.findRelatedFiles(options.feature);
  const packageContent = generator.generateContextPackage(options.feature, relatedFiles);
  const markdown = generator.renderContextPackage(packageContent);

  // Create output directory if it doesn't exist
  if (!fs.existsSync(options.output)) {
    fs.mkdirSync(options.output, { recursive: true });
  }

  // Write context package file
  const outputFile = path.join(options.output, `${options.feature}-complete.md`);
  fs.writeFileSync(outputFile, markdown);

  spinner.succeed(`Generated context package: ${outputFile}`);

  // Show summary
  console.log(chalk.blue('\n## Context Package Summary\n'));
  console.log(`- Feature: ${options.feature}`);
  console.log(`- Types: ${Object.keys(packageContent.types).length}`);
  console.log(`- Components: ${Object.keys(packageContent.components).length}`);
  console.log(`- APIs: ${Object.keys(packageContent.apis).length}`);
  console.log(`- Hooks: ${Object.keys(packageContent.hooks).length}`);
  console.log(`- Patterns: ${packageContent.patterns.length}`);
  console.log(`- Examples: ${packageContent.examples.length}`);
}

export default ContextPackageGenerator;