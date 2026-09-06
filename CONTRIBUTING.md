# Contributing

There is no real requirements for contributing currently, just as long as the CI passes and you have manually tested your changes, you are good to go. Though in saying that, there is a few guidelines.

## Guidelines

### AI Disclosure

If you are using AI to help you write code (or do anything else in the project), then please disclose that in your PR.  
There is nothing wrong with using AI, but it is important to disclose it for transparency. Whether you use AI or not, the code will be reviewed in the same way, and will be held to the same standards.

### PR

When making a PR, please make sure to follow the following guidelines:

1. Make sure your PR is descriptive and explains what it does, and why it does it.
2. Make sure your PR is not too large, and is focused on single changes or features. If it is too large, it will be harder to review and will take longer to get merged.
3. Make sure your PR is not a duplicate of an existing PR. If it is, please close your PR and comment on the existing PR instead.
4. Please do not use AI to write your PR description, as it is important to explain your changes in your own words.
5. If asked to make changes to your PR, please do it in the same PR, and do not create a new PR for the same changes.

### Testing

When testing your changes, please make sure to test them thoroughly. Due to the nature of the project, it is very easy to break things and introduce memory leaks and other bugs. Please test thoroughly and make sure your changes do not affect anything it should not.  
Also do not forget to add tests for your changes.

### Documentation

When adding new features or making changes to existing features, please make sure to update the documentation accordingly. This includes updating any related commenting or documentation files.

## Running the project

To run the project, you either need a linux environment (highly recommended) or a windows environment with WSL2/Docker installed.  
If you are not on linux, then good luck, as if this message is still here then no one has made info on how to run it on windows yet.

1. Clone the repository
```bash
git clone https://github.com/SeradedStripes/asmvil
```

2. Change into the project directory
```bash
cd asmvil
```

3. Run the just file to build the project (or use the command in the justfile)
```bash
just build
```

4. Run the project like any other binary

