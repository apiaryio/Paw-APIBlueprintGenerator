Paw API Blueprint Generator Extension
====================================

Paw extension providing support to export API Blueprint as a code generator.

![](Screenshot.png)

### Installation

The [Paw extension](http://luckymarmot.com/paw/extensions/APIBlueprintGenerator) can be installed with one simple step by clicking [here](paw://extensions/io.apiary.PawExtensions.APIBlueprintGenerator?install).

#### Development Instructions

If you would like to develop the extension, you have follow these steps to get a development environment setup.

##### Prerequisites

Coffee Script is required to build the extension.

```bash
$ brew install npm
$ npm install -g coffee-script
```

##### Development Installation

Once you have Coffee Script installed, you can then clone and build the extension by doing the following:

```bash
$ git clone https://github.com/apiaryio/Paw-APIBlueprintGenerator ~/Library/Containers/com.luckymarmot.Paw/Data/Library/Application\ Support/com.luckymarmot.Paw/Extensions/io.apiary.PawExtensions.APIBlueprintGenerator
$ cd ~/Library/Containers/com.luckymarmot.Paw/Data/Library/Application\ Support/com.luckymarmot.Paw/Extensions/io.apiary.PawExtensions.APIBlueprintGenerator
$ cake build
```

### License

MIT License. See the [LICENSE](LICENSE) file.

