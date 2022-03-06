# Deploy app

echo '{ "jobName": "Deploy Static Web App", "appLocation": "app", "apiLocation": "api", "outputLocation": "wwwroot" }' `
    | gh workflow run "App Deploy Dispatch" --repo devkimchi/ASWA-AutoPilot-Sample --json
