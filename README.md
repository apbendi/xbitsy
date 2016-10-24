# XBitsy

XBitsy is an interpreter for the [Bitsy](https://github.com/apbendi/bitsyspec)
language implemented in Elixir.

## Bitsy

[Bitsy](https://github.com/apbendi/bitsyspec) is a programming language which
aims to be the best language to implement
when building your first compiler or interpreter. It is a resource for
programmers learning about language design.

To learn more about Bitsy or to try implementing it yourself, in your favorite
language, check out the runnable, test based language specification,
[BitsySpec](https://github.com/apbendi/bitsyspec).

You can read more about the motivation behind creating Bitsy on the
[ScopeLift Blog](http://www.scopelift.co/blog/introducing-bitsy-the-first-language-youll-implement-yourself).

For an alternative implementation of Bitsy, check out the
[BitsySwift](https://github.com/apbendi/bitsy-swift) compiler.

I spoke about creating Bitsy and implementing it in Swift at
[360iDev](http://360idev.com/sessions/300-compilers-arent-magic-lets-build-one-swift/)
and
[Indie DevStock](http://indiedevstock.com/speakers/ben-difrancesco/). Videos forthcoming!


## Requirements

XBitsy requires Elixir 1.3.2 or later. It has been tested on OS X El Capitan (10.11.6), but
should work on other versions of OS X/macOS or Linux without issue. If you have one, please report it!

## Installation and Usage

To "install" XBitsy, simply clone the repository and run `mix escript.build`
This places a runnable `xbitsy` "binary" in the main directory, which can be
pointed at any Bitsy source file.

```bash
git clone https://github.com/apbendi/xbitsy.git
cd xbitsy
mix escript.build
./xbitsy examples/fibonacci.bitsy
```

## Contributing

Contributions of all types are welcome! Open an issue, create a pull request,
or just ask a question. The only requirement is that you be respectful of
others.

Please checkout the [BitsySpec](https://github.com/apbendi/bitsyspec) repo and join
the discussion to codify version 1.0 of the Bitsy language specification.


## Resources

While Bitsy has been created partially in response to a perceived lack of approachable
resources for learning language implementation, there are still some good
places to start. The resources focus on language compilation, but building a compiler
or an interpreter shares much in common.

 * [Let's Build a Compiler](http://www.compilers.iecc.com/crenshaw/); this
   paper from the late 80's (!) is an excellent introduction to compilation.
   The biggest downside is the use of
   [Pascal](https://en.wikipedia.org/wiki/Pascal_%28programming_language%29)
   and [m68K](https://en.wikipedia.org/wiki/Motorola_68000) assembly. While working
   through this tutorial, I
   [partially translate](https://github.com/apbendi/LetsBuildACompilerInSwift)
   his code to Swift.
 * [The Super Tiny Compiler](https://github.com/thejameskyle/the-super-tiny-compiler)
   is a great resource by James Kyle- a minimal, extremely well commented compiler
   written in JavaScript. Be sure to also checkout the associated
   [conference talk](https://www.youtube.com/watch?v=Tar4WgAfMr4)
 * [How to implement a programming language in JavaScript](http://lisperator.net/pltut/)
   is a slightly more advanced resource which is, for better or worse, also
   written in JavaScript.
 * [A Nanopass Framework for Compiler Education (PDF)](http://www.cs.indiana.edu/~dyb/pubs/nano-jfp.pdf)
 * [Stanford Compiler Course](https://www.youtube.com/watch?v=sm0QQO-WZlM&list=PLFB9EC7B8FE963EB8)
   with Alex Aiken; an advanced resource for learning some theory and going
   deeper.
