# Contributing

Thanks for your interest in contributing to this project!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/onepiece-data-pipeline.git`
3. Create a branch: `git checkout -b feature/your-feature-name`

## Development Setup

```bash
docker-compose up -d
```

## Making Changes

1. Make your changes
2. Test locally with `docker-compose up -d`
3. Run dbt tests: `dbt test --profiles-dir .`
4. Commit with clear messages

## Pull Request Process

1. Update README.md if needed
2. Ensure all tests pass
3. Submit PR with description of changes

## Code Style

- Python: Follow PEP 8
- SQL: Lowercase keywords, snake_case for identifiers
- dbt: Use staging → intermediate → marts pattern

## Questions?

Open an issue for discussion.
