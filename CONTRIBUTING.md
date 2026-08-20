# Contributing

Install Foundry and Node.js 20 or newer, then install dependencies with `npm install`.

Before opening a pull request, run:

```sh
npm run fmt
npm run build
npm test
npm run test:fuzz
npm run oracle:check
npm run package:check
npm run gas
npm run snapshot:check
```

Changes to numerical methods should include representative examples, boundary cases, fuzz properties, an accuracy
comparison, and a gas comparison. Do not weaken an existing tolerance merely to make a regression pass; explain and
document any intentional accuracy tradeoff.
