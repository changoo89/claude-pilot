#!/usr/bin/env node

/**
 * Smart Import Generator
 *
 * Analyzes TypeScript files to generate optimized imports
 * and detect circular dependencies
 */

import { parse } from '@typescript-eslint/parser';
import { TSESTree } from '@typescript-eslint/typescript-estree';
import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

class SmartImportGenerator {
  constructor() {
    this.imports = new Map();
    this.exports = new Map();
    this.dependencies = new Map();
    this.circularRefs = [];
    this.typeDefinitions = new Map();
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
   * Extract imports from AST
   */
  extractImports(ast, filePath) {
    const imports = [];
    const relativePath = path.relative(process.cwd(), filePath);

    TSESTree.simpleTraverse(ast, {
      ImportDeclaration(node) {
        const importInfo = {
          source: node.source.value,
          specifiers: [],
          isTypeOnly: node.importKind === 'type',
          line: node.loc.start.line
        };

        node.specifiers.forEach(spec => {
          if (spec.type === 'ImportDefaultSpecifier') {
            importInfo.specifiers.push({
              type: 'default',
              local: spec.local.name,
              imported: 'default'
            });
          } else if (spec.type === 'ImportSpecifier') {
            importInfo.specifiers.push({
              type: 'named',
              local: spec.local.name,
              imported: spec.imported.name,
              isType: spec.importKind === 'type'
            });
          } else if (spec.type === 'ImportNamespaceSpecifier') {
            importInfo.specifiers.push({
              type: 'namespace',
              local: spec.local.name,
              imported: '*'
            });
          }
        });

        imports.push(importInfo);
      }
    });

    this.imports.set(relativePath, imports);
    return imports;
  }

  /**
   * Extract exports from AST
   */
  extractExports(ast, filePath) {
    const exports = [];
    const relativePath = path.relative(process.cwd(), filePath);

    TSESTree.simpleTraverse(ast, {
      ExportNamedDeclaration(node) {
        const exportInfo = {
          type: 'named',
          specifiers: [],
          source: node.source ? node.source.value : null,
          isTypeOnly: node.exportKind === 'type',
          line: node.loc.start.line
        };

        if (node.declaration) {
          if (node.declaration.type === 'VariableDeclaration') {
            node.declaration.declarations.forEach(decl => {
              exportInfo.specifiers.push({
                name: decl.id.name,
                type: 'variable'
              });
            });
          } else if (node.declaration.type === 'FunctionDeclaration' && node.declaration.id) {
            exportInfo.specifiers.push({
              name: node.declaration.id.name,
              type: 'function'
            });
          } else if (node.declaration.type === 'TSInterfaceDeclaration') {
            exportInfo.specifiers.push({
              name: node.declaration.id.name,
              type: 'interface'
            });
          } else if (node.declaration.type === 'TSTypeAliasDeclaration') {
            exportInfo.specifiers.push({
              name: node.declaration.id.name,
              type: 'type'
            });
          }
        }

        if (node.specifiers) {
          node.specifiers.forEach(spec => {
            exportInfo.specifiers.push({
              name: spec.local.name,
              type: 'specifier',
              exported: spec.exported.name
            });
          });
        }

        exports.push(exportInfo);
      },

      ExportDefaultDeclaration(node) {
        let name = 'default';
        let type = 'default';

        if (node.declaration) {
          if (node.declaration.type === 'Identifier') {
            name = node.declaration.name;
            type = 'identifier';
          } else if (node.declaration.id) {
            name = node.declaration.id.name;
            type = node.declaration.type.replace('Declaration', '').toLowerCase();
          } else if (node.declaration.type === 'ArrowFunctionExpression') {
            type = 'arrow_function';
          } else if (node.declaration.type === 'FunctionExpression') {
            type = 'function_expression';
          }
        }

        exports.push({
          type: 'default',
          name,
          declarationType: type,
          line: node.loc.start.line
        });
      }
    });

    this.exports.set(relativePath, exports);
    return exports;
  }

  /**
   * Analyze dependencies and detect circular references
   */
  analyzeDependencies() {
    const graph = new Map();

    // Build dependency graph
    this.imports.forEach((imports, file) => {
      graph.set(file, new Set());

      imports.forEach(importInfo => {
        // Convert relative imports to absolute file paths
        if (importInfo.source.startsWith('./') || importInfo.source.startsWith('../')) {
          const resolvedPath = this.resolveImportPath(file, importInfo.source);
          if (resolvedPath) {
            graph.get(file).add(resolvedPath);
          }
        }
      });
    });

    // Detect circular dependencies
    const visited = new Set();
    const recursionStack = new Set();

    const detectCycle = (node, path = []) => {
      if (recursionStack.has(node)) {
        const cycleStart = path.indexOf(node);
        if (cycleStart !== -1) {
          this.circularRefs.push(path.slice(cycleStart).concat(node));
        }
        return;
      }

      if (visited.has(node)) return;

      visited.add(node);
      recursionStack.add(node);

      const dependencies = graph.get(node) || new Set();
      dependencies.forEach(dep => {
        detectCycle(dep, [...path, node]);
      });

      recursionStack.delete(node);
    };

    graph.forEach((_, node) => {
      if (!visited.has(node)) {
        detectCycle(node);
      }
    });

    this.dependencies = graph;
    return graph;
  }

  /**
   * Resolve import path to file path
   */
  resolveImportPath(fromFile, importPath) {
    const fromDir = path.dirname(fromFile);
    let resolvedPath = path.posix.normalize(
      path.posix.join(fromDir, importPath)
    );

    // Try different extensions
    const extensions = ['', '.ts', '.tsx', '.js', '.jsx', '/index.ts', '/index.tsx', '/index.js', '/index.jsx'];

    for (const ext of extensions) {
      const testPath = resolvedPath + ext;
      if (this.imports.has(testPath) || this.exports.has(testPath)) {
        return testPath;
      }
    }

    return null;
  }

  /**
   * Generate optimized imports for a file
   */
  generateOptimizedImports(filePath) {
    const ast = this.parseFile(filePath);
    if (!ast) return null;

    const usedIdentifiers = new Set();
    const typeIdentifiers = new Set();
    const fileImports = new Map();

    // Find all used identifiers
    TSESTree.simpleTraverse(ast, {
      Identifier(node) {
        if (node.parent.type !== 'ImportSpecifier' &&
            node.parent.type !== 'ImportDefaultSpecifier' &&
            node.parent.type !== 'ImportNamespaceSpecifier') {
          usedIdentifiers.add(node.name);
        }
      },

      // Track type usage
      TSTypeReference(node) {
        if (node.typeName.type === 'Identifier') {
          typeIdentifiers.add(node.typeName.name);
        } else if (node.typeName.type === 'TSQualifiedName') {
          // Handle Type.SubType pattern
          let current = node.typeName;
          while (current.object) {
            if (current.object.type === 'Identifier') {
              typeIdentifiers.add(current.object.name);
            }
            current = current.object;
          }
        }
      }
    });

    // Analyze existing imports
    this.extractImports(ast, filePath);
    const imports = this.imports.get(path.relative(process.cwd(), filePath)) || [];

    // Group imports by source
    imports.forEach(importInfo => {
      const key = importInfo.source;
      if (!fileImports.has(key)) {
        fileImports.set(key, {
          source: importInfo.source,
          defaultImport: null,
          namespaceImport: null,
          namedImports: [],
          typeImports: [],
          isTypeOnly: importInfo.isTypeOnly
        });
      }

      const grouped = fileImports.get(key);
      importInfo.specifiers.forEach(spec => {
        if (spec.type === 'default') {
          grouped.defaultImport = spec.local;
        } else if (spec.type === 'namespace') {
          grouped.namespaceImport = spec.local;
        } else if (spec.type === 'named') {
          if (spec.isType || typeIdentifiers.has(spec.imported)) {
            grouped.typeImports.push(spec);
          } else if (usedIdentifiers.has(spec.local)) {
            grouped.namedImports.push(spec);
          }
        }
      });
    });

    // Generate optimized import statements
    const optimizedImports = [];
    fileImports.forEach(group => {
      if (group.defaultImport && !usedIdentifiers.has(group.defaultImport)) {
        // Remove unused default import
        return;
      }

      const hasTypes = group.typeImports.length > 0;
      const hasValues = group.defaultImport || group.namespaceImport || group.namedImports.length > 0;

      if (hasTypes && !hasValues) {
        // Type-only import
        optimizedImports.push(this.generateTypeImport(group));
      } else if (hasTypes && hasValues) {
        // Separate type and value imports
        if (group.typeImports.length > 0) {
          optimizedImports.push(this.generateTypeImport(group));
        }
        optimizedImports.push(this.generateValueImport(group));
      } else {
        // Value-only import
        optimizedImports.push(this.generateValueImport(group));
      }
    });

    // Sort imports: external libraries first, then internal modules
    optimizedImports.sort((a, b) => {
      const aIsExternal = /^[a-zA-Z]/.test(a.source);
      const bIsExternal = /^[a-zA-Z]/.test(b.source);

      if (aIsExternal && !bIsExternal) return -1;
      if (!aIsExternal && bIsExternal) return 1;
      return a.source.localeCompare(b.source);
    });

    return {
      original: imports,
      optimized: optimizedImports,
      unused: this.findUnusedImports(imports, usedIdentifiers, typeIdentifiers),
      missing: this.findMissingImports(ast, usedIdentifiers)
    };
  }

  /**
   * Generate type import statement
   */
  generateTypeImport(group) {
    const parts = [];

    if (group.typeImports.length > 0) {
      const named = group.typeImports
        .map(spec => spec.imported === spec.local ? spec.imported : `${spec.imported} as ${spec.local}`)
        .join(', ');
      parts.push(`{ ${named} }`);
    }

    return {
      source: group.source,
      statement: `import type ${parts.join(', ')} from '${group.source}';`,
      isTypeOnly: true
    };
  }

  /**
   * Generate value import statement
   */
  generateValueImport(group) {
    const parts = [];

    if (group.defaultImport) {
      parts.push(group.defaultImport);
    }

    if (group.namedImports.length > 0) {
      const named = group.namedImports
        .map(spec => spec.imported === spec.local ? spec.imported : `${spec.imported} as ${spec.local}`)
        .join(', ');
      parts.push(`{ ${named} }`);
    }

    if (group.namespaceImport) {
      parts.push(`* as ${group.namespaceImport}`);
    }

    return {
      source: group.source,
      statement: `import ${parts.join(', ')} from '${group.source}';`,
      isTypeOnly: false
    };
  }

  /**
   * Find unused imports
   */
  findUnusedImports(imports, usedIdentifiers, typeIdentifiers) {
    const unused = [];

    imports.forEach(importInfo => {
      importInfo.specifiers.forEach(spec => {
        const isUsed = usedIdentifiers.has(spec.local) || typeIdentifiers.has(spec.local);
        if (!isUsed && spec.local !== spec.imported) {
          // Skip renamed imports where local name might be different
          unused.push({
            name: spec.local,
            source: importInfo.source,
            line: importInfo.line
          });
        }
      });
    });

    return unused;
  }

  /**
   * Find potentially missing imports (heuristics)
   */
  findMissingImports(ast, usedIdentifiers) {
    // This is a simple heuristic - in practice, you'd need type analysis
    const reactHooks = ['useState', 'useEffect', 'useCallback', 'useMemo', 'useRef'];
    const missing = [];

    reactHooks.forEach(hook => {
      if (usedIdentifiers.has(hook)) {
        missing.push({
          name: hook,
          source: 'react',
          priority: 'high'
        });
      }
    });

    return missing;
  }

  /**
   * Generate import optimization report
   */
  generateReport() {
    const report = {
      summary: {
        totalFiles: this.imports.size,
        totalImports: 0,
        circularDependencies: this.circularRefs.length
      },
      files: {},
      recommendations: []
    };

    // Count imports
    this.imports.forEach(imports => {
      report.summary.totalImports += imports.length;
    });

    // Analyze each file
    this.imports.forEach((imports, file) => {
      const optimization = this.generateOptimizedImports(file);
      if (optimization) {
        report.files[file] = {
          imports: imports.length,
          unused: optimization.unused.length,
          optimized: optimization.optimized.length,
          missing: optimization.missing.length,
          suggestions: optimization
        };

        // Add recommendations
        if (optimization.unused.length > 0) {
          report.recommendations.push({
            file,
            type: 'remove_unused',
            imports: optimization.unused
          });
        }

        if (optimization.missing.length > 0) {
          report.recommendations.push({
            file,
            type: 'add_missing',
            imports: optimization.missing
          });
        }
      }
    });

    // Add circular dependency recommendations
    this.circularRefs.forEach(cycle => {
      report.recommendations.push({
        type: 'circular_dependency',
        cycle,
        priority: 'high',
        message: `Circular dependency detected: ${cycle.join(' → ')}`
      });
    });

    return report;
  }

  /**
   * Generate import fixes
   */
  generateFixes(report) {
    const fixes = [];

    report.recommendations.forEach(rec => {
      if (rec.type === 'remove_unused' && rec.imports) {
        fixes.push({
          file: rec.file,
          type: 'delete_lines',
          lines: rec.imports.map(imp => imp.line),
          message: `Remove unused import(s): ${rec.imports.map(imp => imp.name).join(', ')}`
        });
      }

      if (rec.type === 'add_missing' && rec.imports) {
        fixes.push({
          file: rec.file,
          type: 'add_imports',
          imports: rec.imports,
          message: `Add missing import(s): ${rec.imports.map(imp => imp.name).join(', ')}`
        });
      }
    });

    return fixes;
  }

  /**
   * Analyze all TypeScript files
   */
  analyzeAll() {
    const files = glob.sync('**/*.{ts,tsx}', {
      ignore: ['node_modules/**', '.next/**', 'out/**']
    });

    files.forEach(file => {
      const ast = this.parseFile(file);
      if (ast) {
        this.extractImports(ast, file);
        this.extractExports(ast, file);
      }
    });

    this.analyzeDependencies();
    return this.generateReport();
  }

  /**
   * Generate markdown report
   */
  generateMarkdownReport(report) {
    let markdown = '# Smart Import Analysis Report\n\n';
    markdown += `Generated on: ${new Date().toISOString()}\n\n`;

    // Summary
    markdown += '## Summary\n\n';
    markdown += `- **Total Files**: ${report.summary.totalFiles}\n`;
    markdown += `- **Total Imports**: ${report.summary.totalImports}\n`;
    markdown += `- **Circular Dependencies**: ${report.summary.circularDependencies}\n\n`;

    // Circular Dependencies
    if (this.circularRefs.length > 0) {
      markdown += '## ⚠️ Circular Dependencies\n\n';
      this.circularRefs.forEach((cycle, i) => {
        markdown += `### Cycle ${i + 1}\n`;
        markdown += `${cycle.join(' → ')}\n\n`;
      });
    }

    // Recommendations
    if (report.recommendations.length > 0) {
      markdown += '## Recommendations\n\n';

      // Group by file
      const byFile = {};
      report.recommendations.forEach(rec => {
        if (rec.file) {
          if (!byFile[rec.file]) byFile[rec.file] = [];
          byFile[rec.file].push(rec);
        }
      });

      Object.entries(byFile).forEach(([file, recs]) => {
        markdown += `### ${file}\n\n`;
        recs.forEach(rec => {
          switch (rec.type) {
            case 'remove_unused':
              markdown += `- 🗑️ Remove unused imports: ${rec.imports.map(i => i.name).join(', ')}\n`;
              break;
            case 'add_missing':
              markdown += `- ➕ Add missing imports: ${rec.imports.map(i => `${i.name} from '${i.source}'`).join(', ')}\n`;
              break;
          }
        });
        markdown += '\n';
      });
    }

    return markdown;
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const generator = new SmartImportGenerator();
  const report = generator.analyzeAll();

  console.log('Analyzing imports...');

  const outputDir = '.claude/generated';
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const reportPath = path.join(outputDir, 'import-analysis.md');
  const markdown = generator.generateMarkdownReport(report);

  fs.writeFileSync(reportPath, markdown);
  console.log(`Import analysis report generated: ${reportPath}`);

  // Generate fixes file
  const fixes = generator.generateFixes(report);
  const fixesPath = path.join(outputDir, 'import-fixes.json');
  fs.writeFileSync(fixesPath, JSON.stringify(fixes, null, 2));
  console.log(`Import fixes saved: ${fixesPath}`);

  // Also output full report as JSON
  const jsonPath = path.join(outputDir, 'import-analysis.json');
  fs.writeFileSync(jsonPath, JSON.stringify(report, null, 2));
  console.log(`Full analysis saved: ${jsonPath}`);
}

export default SmartImportGenerator;