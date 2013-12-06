# Divine Player SWF

This is the flash player used by [divine-player](https://raw.github.com/cameronhunter/divine-player).

## Dev setup
1. Clone the repository:
```
git clone git@github.com:cameronhunter/divine-player-swf.git
```

2. Install the dependencies (from the project root):
```
npm install -g bower grunt-cli
npm install && bower install
```

3. Install [Flex SDK](http://sourceforge.net/adobe/flexsdk/wiki/Flex SDK/) and add it to your `PATH`

4. Build the project to check that everything works
```
grunt build
```

## Building
You can build the project using `grunt build`. This creates a `release` folder containing the compiled SWF.

## Testing

```shell
grunt test
```

This starts a [local server](http://localhost:9001) which you can point devices to.

Integration testing is currently performed in [divine-player](https://github.com/cameronhunter/divine-player).
