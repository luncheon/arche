# arche

non-designer's icon designer written in [Mint](https://www.mint-lang.com/).

## Development

```bash
brew tap homebrew-community/alpha
brew install mint-lang
```

```bash
mint start --auto-format
```

## Build

```bash
rm -rf docs/ dist/ && mint build -r --skip-service-worker && rm dist/*.png && cp assets/icon.png dist/ && mv dist/ docs/
```
