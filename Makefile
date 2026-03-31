.PHONY: sqlfix sqllint lint sqlfix-file sqllint-file

sqlfix:
	./.venv/bin/sqlfluff fix dbt/olist_dbt/models --config .sqlfluff

sqllint:
	./.venv/bin/sqlfluff lint dbt/olist_dbt/models --config .sqlfluff

lint:
	./.venv/bin/pre-commit run --all-files

sqlfix-file:
	@if [ -z "$(FILE)" ]; then echo "Usage: make sqlfix-file FILE=path/to/file.sql"; exit 1; fi
	./.venv/bin/sqlfluff fix $(FILE) --config .sqlfluff

sqllint-file:
	@if [ -z "$(FILE)" ]; then echo "Usage: make sqllint-file FILE=path/to/file.sql"; exit 1; fi
	./.venv/bin/sqlfluff lint $(FILE) --config .sqlfluff
