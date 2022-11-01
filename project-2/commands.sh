# preparing venv for the app
make setup

# installing dependencies
make install

# running linter
make lint

# running tests
make test

# running app locally
python app.py

# deploying the app to Azure App Service
az webapp up -n project-2-cqsirdapvqvsqkvf

# streaming logs from the app
az webapp log tail --resource-group dawwido_rg_1980 --name project-2-cqsirdapvqvsqkvf
