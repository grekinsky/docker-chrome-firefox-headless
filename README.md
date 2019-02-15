# docker-chrome-firefox-headless
> Docker chrome and firefox headless with node.js and npm

This image is for running e2e tests using javascript frameworks like Cucumber.js. Chrome and Firefox are available to run using selenium.

### Example:

```
FROM grekinsky/docker-chrome-firefox-headless:latest

ENV HOME=/home/ubrowser/src/app

COPY package*.json $HOME/

RUN npm install

COPY . $HOME
```

Then you can add a volume where the test results are stored to persist data:

```
docker run \
    -v `pwd`/logs:/home/ubrowser/src/app/logs \
    my-testimage
```
