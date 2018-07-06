# NiMMbus Embedded

[![MIT License](https://img.shields.io/github/license/kmbn/nimmbus-embedded.svg?style=flat-square)](https://raw.githubusercontent.com/kmbn/nimmbus-embedded/master/LICENSE)

A proof of concept for embedding NiMMbus feedback in a website via an Elm application.

Currently supported:
- Retrieving feedback for a citation from a NiMMbus instance
- Displaying the title, author and date of each item of feedback
- Calling the NiMMbus API to create a new citation if none exists
- Calling the NiMMbus API to add feedback to an existing citation

## Usage
This Elm application compiles to JavaScript which can then be embedded in HTML. You will need to have Elm installed in order to compile the application.

### Create the embeddable script
To create the embeddable script:

```
git clone https://github.com/kmbn/nimmbus-embedded.git
cd nimmbus-embedded
elm-make src/Main.elm --output=compiled/nimmbus.js
```

You'll find the script, `nimmbus.js`, in `nimmbus-embedded/compiled`.

### Embed the script
To embed the script, include the script itself in the `<head>` of your HTML and then call it in the `<body>` of your HTML.

You must pass the citationId, citationNamespace and citationTitle, which are required by NiMMbus itself, to the script.

Example:

```html
<!DOCTYPE HTML>
<html>
    <head>
        <script src="nimmbus.js"></script>
    </head>
    <body>
        <script>Elm.Main.fullscreen({citationId: "foo", citationNamespace: "bar", citationTitle: "baz"})</script>
    </body>
</html>
```

## License
MIT

## Copyright
&copy; 2018 Kevin Brochet-Nguyen