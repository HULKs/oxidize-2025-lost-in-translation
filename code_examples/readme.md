## Workflow to generate pretty compiler errors

- Write example code into a new file in ./examples
- Run `RUSTFLAGS=-Awarnings cargo --color always build --quiet --example example_name 2> compiler_error.txt`
- Trim the resulting file to your liking
- Upload to assets/compiler-errors
- Use `render-compiler-error` function in Typst
