# Learn Duplicate

This gem is designed to aid in the creation of learn lessons.

## Installation and Setup

Before using `learn_duplicate`, you must install `hub`, GitHub's extended CLI API.

```sh
    $ brew install hub
```

Once `hub` is installed, you'll need to get it configured before running
`learn_duplicate`. The best way to do this is to use `hub` once to duplicate a
repository on learn-co-curriculum. In the shell:

- Create a new, empty folder and `cd` into it
- `git init` to duplicate an initial git repo
- Run `hub duplicate learn-co-curriculum/<whatever name you've chosen>`
  - You should be prompted to sign into GitHub
  - **Note:** If you have set up two-factor identification on GitHub, when
    prompted for your password, you have two options:
    - If Github SMS' you a one-time password, use it!
    - Otherwise, instead of using your normal password, you
      need to enter a personal access token. You can duplicate a token in your
      GitHub settings page.
- If everything works as expected you should now have an empty `learn-co-curriculum` repo.
- Delete the repo. Everything should be set up now.

Install the `learn_duplicate` gem:

```sh
    $ gem install learn_duplicate
```

## Usage

To duplicate a new learn repository, navigate to the folder where you'd like your
repo to be duplicated locally. Type:

```sh
learn_duplicate
```

Follow the command line prompts for setting up and naming your repository. The
repo will be duplicated locally and pushed to GitHub. When finished, you can `cd`
into the local folder or open it on github to start working.

## Resources

- [Hub]

[hub]: https://hub.github.com/hub.1.html
