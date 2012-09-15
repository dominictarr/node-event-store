node-event-store
================

This package provides support for an event-sourced persistence strategy leveraging node.js's `Stream` interface.

This exposes the wonderful `pipe` for reading events into and out of Aggregate roots while making it easy to pipe into your publisher(s).

## Install

`npm install node-event-store`

## Supported DBs

Currently, only `redis`.

`npm install node-event-store-redis`

## Examples

Please see the `test` folder for examples. Especially `event-store.spec.coffee`.


## Testing

    make test

Or for integration testing

    make TEST_TYPE=integration test

## License

Copyright (c) 2012 Mike Nichols

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
