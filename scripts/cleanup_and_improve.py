#!/usr/bin/env python3
"""
Comprehensive cleanup and improvement script for Onyx (Danswer) repository.
This script performs security checks, code quality improvements, and cleanup tasks.
"""

import os
import subprocess
import sys
import json
from pathlib import Path
from typing import List, Dict, Any

class OnyxCleanupTool:
    def __init__(self, repo_root: str):
        self.repo_root = Path(repo_root)
        self.backend_dir = self.repo_root / "backend"
        self.web_dir = self.repo_root / "web"
        
    def run_command(self, cmd: List[str], cwd: Path = None) -> tuple[int, str, str]:
        """Run a command and return exit code, stdout, stderr."""
        try:
            result = subprocess.run(
                cmd, 
                cwd=cwd or self.repo_root,
                capture_output=True,
                text=True,
                timeout=300
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return -1, "", "Command timed out"
        except Exception as e:
            return -1, "", str(e)
    
    def check_security_issues(self) -> Dict[str, Any]:
        """Check for common security issues."""
        issues = {
            "sensitive_files": [],
            "hardcoded_secrets": [],
            "insecure_dependencies": []
        }
        
        # Check for sensitive files
        sensitive_patterns = [
            "*.key", "*.pem", "*.p12", "*.pfx", 
            ".env", "secrets.*", "*.secret"
        ]
        
        for pattern in sensitive_patterns:
            code, stdout, _ = self.run_command(["find", ".", "-name", pattern, "-type", "f"])
            if code == 0 and stdout.strip():
                issues["sensitive_files"].extend(stdout.strip().split('\n'))
        
        # Check for hardcoded secrets in code
        secret_patterns = [
            r"password\s*=\s*['\"][^'\"]+['\"]",
            r"api_key\s*=\s*['\"][^'\"]+['\"]",
            r"secret\s*=\s*['\"][^'\"]+['\"]",
            r"token\s*=\s*['\"][^'\"]+['\"]"
        ]
        
        for pattern in secret_patterns:
            code, stdout, _ = self.run_command([
                "grep", "-r", "-i", "-E", pattern, 
                "--include=*.py", "--include=*.js", "--include=*.ts", 
                "--include=*.tsx", "--include=*.json", "."
            ])
            if code == 0 and stdout.strip():
                issues["hardcoded_secrets"].extend(stdout.strip().split('\n'))
        
        return issues
    
    def check_code_quality(self) -> Dict[str, Any]:
        """Check code quality issues."""
        quality_issues = {
            "python_issues": [],
            "javascript_issues": [],
            "unused_imports": [],
            "large_files": []
        }
        
        # Check for large files (>1MB)
        code, stdout, _ = self.run_command(["find", ".", "-type", "f", "-size", "+1M"])
        if code == 0 and stdout.strip():
            quality_issues["large_files"] = [
                f for f in stdout.strip().split('\n') 
                if not f.startswith('./.git/')
            ]
        
        return quality_issues
    
    def cleanup_files(self) -> List[str]:
        """Clean up unnecessary files."""
        cleaned_files = []
        
        # Remove common temporary files
        temp_patterns = [
            "*.tmp", "*.temp", "*.log", "*.cache",
            "__pycache__", "*.pyc", "*.pyo", ".DS_Store"
        ]
        
        for pattern in temp_patterns:
            code, stdout, _ = self.run_command(["find", ".", "-name", pattern, "-type", "f"])
            if code == 0 and stdout.strip():
                files = stdout.strip().split('\n')
                for file in files:
                    try:
                        os.remove(file)
                        cleaned_files.append(file)
                    except OSError:
                        pass
        
        return cleaned_files
    
    def generate_report(self) -> str:
        """Generate a comprehensive cleanup and improvement report."""
        print("🔍 Running security checks...")
        security_issues = self.check_security_issues()
        
        print("📊 Checking code quality...")
        quality_issues = self.check_code_quality()
        
        print("🧹 Cleaning up files...")
        cleaned_files = self.cleanup_files()
        
        # Generate report
        report = f"""
# Onyx Repository Cleanup and Improvement Report

## Security Analysis
### Sensitive Files Found:
{chr(10).join(f"- {f}" for f in security_issues['sensitive_files']) or "✅ No sensitive files found"}

### Potential Hardcoded Secrets:
{chr(10).join(f"- {s}" for s in security_issues['hardcoded_secrets'][:10]) or "✅ No hardcoded secrets detected"}

## Code Quality Issues
### Large Files (>1MB):
{chr(10).join(f"- {f}" for f in quality_issues['large_files']) or "✅ No large files found"}

## Cleanup Results
### Files Cleaned:
{chr(10).join(f"- {f}" for f in cleaned_files[:20]) or "✅ No files needed cleaning"}
{f"... and {len(cleaned_files) - 20} more files" if len(cleaned_files) > 20 else ""}

## Recommendations
1. 🔒 Review any sensitive files and ensure they're properly secured
2. 🔑 Implement proper secret management for any hardcoded credentials
3. 📦 Consider updating outdated dependencies (test thoroughly first)
4. 🧪 Run comprehensive tests after any changes
5. 🚀 Set up CI/CD pipeline for automated quality checks

## Next Steps
1. Commit the cleanup changes
2. Set up pre-commit hooks for code quality
3. Configure automated security scanning
4. Implement dependency update automation
5. Deploy to staging environment for testing
"""
        
        return report

def main():
    if len(sys.argv) > 1:
        repo_root = sys.argv[1]
    else:
        repo_root = os.getcwd()
    
    print(f"🚀 Starting Onyx repository cleanup and improvement...")
    print(f"📁 Repository root: {repo_root}")
    
    cleanup_tool = OnyxCleanupTool(repo_root)
    report = cleanup_tool.generate_report()
    
    # Save report
    report_file = Path(repo_root) / "CLEANUP_REPORT.md"
    with open(report_file, 'w') as f:
        f.write(report)
    
    print(f"\n📋 Report saved to: {report_file}")
    print("\n" + "="*60)
    print(report)

if __name__ == "__main__":
    main()