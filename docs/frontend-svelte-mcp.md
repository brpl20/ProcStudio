# Svelte MCP Servers and AI Coding Solutions Research Findings

## Research Overview
This document compiles findings about Svelte MCP (Model Context Protocol) servers and AI-powered solutions for improving Svelte coding, focusing on developments from 2025.

## MCP Servers for Svelte

### 1. svelte-llm by Stanislav Khromov
- **URL**: https://svelte-llm.stanislav.garden/
- **GitHub**: https://github.com/khromov/llmctx
- **Author**: Stanislav Khromov
- **Last Updated**: September 2025 (5 days ago)

**Key Features:**
- Serves latest Svelte and SvelteKit documentation directly from official GitHub repository
- Provides Tools, Resources, and Prompts via MCP protocol
- Tools: `list_sections` and `get_documentation`
- Resources: Each documentation section accessible via URIs like `svelte-llm://docs/svelte/runes`
- Prompts: Curated documentation sets ("svelte-core", "sveltekit-production") and "Svelte Developer" preset
- Documentation automatically fetched and updated hourly
- Multiple preset configurations available

**Supported Clients:**
- Claude Code
- Claude Desktop  
- GitHub Copilot
- Cline
- OpenAI Codex
- Other MCP clients

**Preset Options:**
- AI-condensed version focused on code examples and key concepts
- Complete Svelte + SvelteKit docs (various filtering options)
- Migration-specific documentation
- Individual Svelte 5 or SvelteKit focused docs

### 2. mcp-svelte-docs by Scott Spence (spences10)
- **URL**: https://www.mcpserverfinder.com/servers/spences10/mcp-svelte-docs
- **GitHub**: Available on GitHub
- **Author**: Scott Spence (@spence14)
- **Created**: January 20, 2025
- **Language**: TypeScript
- **Stars**: 25, **Forks**: 4

**Key Features:**
- Advanced caching with LibSQL database
- Sophisticated search capabilities with intelligent relevance scoring
- Document type filtering (API, Tutorial, Example, Error)
- Section hierarchy awareness
- Context-aware result excerpts
- Related search suggestions
- Support for package-specific documentation (Svelte, Kit, CLI)
- Smart content chunking for large documents
- Compressed variants for smaller context windows
- Automatic content freshness checks

**API:**
- Resources: Access via URIs like `svelte-docs://docs/llms.txt`
- Tools: `search_docs` and `get_next_chunk`
- Environment variables: `LIBSQL_URL`, `LIBSQL_AUTH_TOKEN`

**Configuration Examples:**
- Cline MCP settings
- Claude Desktop with WSL
- NPX installation: `npx -y mcp-svelte-docs`

### 3. Astro + Svelte 5 MCP Server by catpaladin
- **URL**: https://lobehub.com/mcp/catpaladin-mcp-frontend-tools
- **Author**: catpaladin
- **Version**: 1.0.0
- **Language**: Go
- **Published**: September 9, 2025

**Key Features:**
- Comprehensive MCP server for Astro with Svelte 5 development
- Built with Go and official MCP Go SDK
- 9 powerful tools for modern web application development

**Core Tools:**
1. Project Creation - Generate new Astro projects with Svelte 5 integration
2. Component Generation - Create Svelte 5 components using modern runes patterns
3. Integration Management - Configure Astro integrations (Tailwind, MDX, etc.)
4. Code Analysis - Comprehensive code review and quality assessment
5. Automatic Fixes - Migrate legacy patterns to modern Svelte 5 and Astro best practices
6. Type Generation - Generate TypeScript definitions for better type safety
7. Performance Optimization - Analyze and suggest build optimizations
8. Code Explanation - Detailed explanations of complex patterns and architectures
9. Project Improvements - Holistic suggestions for better project structure

**Technology Focus:**
- Astro 5.1+ with Content Layer API and enhanced View Transitions
- Svelte 5.15+ with runes (`$state`, `$derived`, `$effect`, `$props`)
- TypeScript 5.7+ with strict configuration
- Modern Build Tools with Vite optimizations

## Additional Research Sources Found

### Articles and Guides
1. "How and why I built an MCP server for Svelte" - Stanislav Khromov (September 2025)
2. "New features in the Svelte MCP server" - Reddit r/sveltejs (August 2025)
3. "The AI Coding Tools I Actually Use (And the Ones I Don't)" - Scott Spence (June 2025)
4. "The Best AI Coding Tools in 2025" - Builder.io (July 2025)
5. "Top 7 MCP Servers for AI-Driven Development" - Medium (June 2025)

### Video Resources
- "MCP/Tools AI assistant in an SvelteKit App (queries local DB)" - YouTube (March 2025)

### Community Discussions
- Reddit discussions about best AI tools for Svelte coding
- GitHub repositories and community contributions

## Next Steps for Research
1. Investigate general AI coding assistants and their Svelte support
2. Research specific AI tools mentioned in the articles
3. Look into integration methods and setup procedures
4. Analyze user experiences and community feedback



## AI Coding Assistants and Tools for Svelte

### 1. Cursor IDE
- **Type**: AI-first code editor
- **Svelte Support**: Excellent with proper configuration
- **Key Features for Svelte**:
  - AI-powered code generation and completion
  - Agent mode for automated development tasks
  - Custom rules system for framework-specific guidance
  - Terminal command automation
  - MCP integration support

**Cursor Rules for Svelte Development:**
- Custom `.cursor/rules` directory configuration
- Specific rule files for Svelte 5, SvelteKit 2, and Tailwind CSS 4
- Auto-attached rules based on file patterns
- Helps AI generate modern, compatible code
- Reduces outdated pattern suggestions

**Cursor Agent Capabilities:**
- Generates initial Svelte components and endpoints from markdown PRDs
- Wraps and iterates backend calls through Svelte endpoints
- Runs terminal commands (dev server, tests, deployment)
- Checks documentation and production environments with MCP
- Automates repetitive development tasks

**Configuration Files:**
- `.cursor/rules/svelte-5.mdc` (Auto Attached to `*.svelte` `*.ts`)
- `.cursor/rules/sveltekit-2.mdc` (Auto Attached to `*.svelte` `*.ts`)
- `.cursor/rules/tailwind-css-4.mdc` (Auto Attached to `*.svelte` `*.css`)

### 2. GitHub Copilot
- **Type**: AI pair programmer
- **Svelte Support**: Limited for Svelte 5 without configuration
- **Current Limitations**: 
  - Training data cutoff at October 2023
  - Does not create Svelte 5 components by default
  - Suggests outdated Svelte 4 patterns

**Optimization for Svelte 5:**
- Custom Copilot instructions available (GitHub Gist by Padi2312)
- Comprehensive guidelines for Svelte 5 syntax and best practices
- Instructions cover runes system, modern patterns, and TypeScript usage

**Copilot Instructions Key Points:**
- Use `$state(value)` for state variables
- Use `$effect(() => { ... })` for effects instead of `$:`
- Use `$derived()` or `$derived.by()` for derived state
- Component props with `type Props = { ... }` and `let { prop } = $props();`
- Normal HTML element events (`onclick` instead of `on:click`)
- Avoid legacy Svelte 3/4 patterns
- TypeScript-first approach with clear type annotations

### 3. Other AI Coding Tools Mentioned

**General AI Coding Assistants (2025):**
- Cursor (AI-first editor)
- GitHub Copilot (Microsoft)
- Cline (VS Code extension)
- Bolt.new (StackBlitz)
- Replit AI
- JetBrains AI Assistant
- Windsurf
- Xcode AI Assistant
- aider

**Specialized Tools:**
- Claude Code (Anthropic)
- OpenAI Codex
- v0 (Vercel)
- Firebase Studio (Gemini-powered)

## Community Insights and Discussions

### Reddit Community Feedback
- Active discussions about AI tools for Svelte development
- Users report mixed experiences with different AI assistants
- Cursor receiving positive feedback from Svelte developers
- GitHub Copilot needs configuration for optimal Svelte 5 support

### Developer Experiences
- Chris Ellis: Uses Cursor AI for SvelteKit development with significant productivity gains
- Travis Horn: Created custom Cursor rules for better Svelte compatibility
- Scott Spence: Built MCP server for Svelte documentation access
- Community preference for AI tools that understand modern Svelte patterns

## Integration and Setup Considerations

### MCP Integration
- Multiple MCP servers available for Svelte documentation
- Can be integrated with various AI clients (Claude, Cursor, etc.)
- Provides real-time access to up-to-date Svelte documentation
- Reduces hallucination and outdated suggestions

### Configuration Best Practices
- Set up custom rules/instructions for AI tools
- Use TypeScript for better AI understanding
- Leverage MCP servers for documentation access
- Regular updates to keep AI tools current with framework changes

### Workflow Integration
- PRD-driven development with AI assistance
- Automated terminal command execution
- Code review and iteration cycles
- Integration with existing development tools and processes

