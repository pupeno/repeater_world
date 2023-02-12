# README

This is a new web application to maintain a list of ham radio repeaters all over the world and export it in the format 
required to import it to various different radios.

## Why does this exist?

Because I couldn't find anything that quite did what I want and I found myself massaging data in spreadsheets way too
much. This should be easier and should be easier for everybody.

I also believe that some information should be, so this project will be open source. I'll maintain it and host it, I'll
review the PRs, but anybody can make new PRs and request changes. Things anybody can do include:

 * Add new sources of repeaters that get imported periodically.
 * Add new export formats so that we can support every radio that exists.
 * Add new features.

## My radio is not supported, can you support it?

Please add a ticket for it on https://github.com/flexpointtech/repeater_world/issues/new but do search in case we 
already have a ticket for it on https://github.com/flexpointtech/repeater_world/issues?q=is%3Aopen+is%3Aissue+label%3Aexporter

We'll try to support it, but we might need your help to test it to see if it works on the radio.

## How do I contribute?

You can clone this repository locally, create a branch for your feature, add any code you want, push it and make a pull
request. When you do that, make sure the tests still pass and the coverage remains high. You can see the coverage in the
`/coverage` folder.

If you want to contribute but you are not sure what to work on, you can change the list of open issues on
https://github.com/flexpointtech/repeater_world/issues

Especially useful would be new importers and exporters.

The rest of the documentation for this project is in the wiki: https://github.com/flexpointtech/repeater_world/wiki

![state](https://github.com/flexpointtech/repeater_world/actions/workflows/push.yml/badge.svg)

## I have a question, where do I ask?

Please, post it here: https://github.com/flexpointtech/repeater_world/discussions
