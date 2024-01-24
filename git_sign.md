## Setting up your machine for signing git commits

### Installing GPG

Besides Git, the only requirement is that you must have GPG installed. I recommend using latest GPG version

* On Windows, you can download the Gpg4win distribution from the GPG website
* On macOS, the easiest thing is to use Homebrew: brew install gpg
* Most Linux distributions come with GPG pre-installed; if not, you can always find it on their official repositories.

**Note** that in some Linux distributions, the application is called gpg2, so you might need to replace gpg with gpg2 in the commands below. In this case, you might also need to run `git config --global gpg.program $(which gpg2)`.


## Enable gpg to use the gpg-agent

You will also need to add these two lines to your profile file (`~/.bashrc`, `~/.bash_profile`, `~/.zprofile`, or wherever appropriate), then re-launch your shell (or run source `~/.bashrc` or similar):

```bash
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent
```

#### Generate a GPG key pair

To start, generate a new GPG key pair (public and private):

```
gpg --full-gen-key
```

Configure the key with:

* Kind of key: type 4 for (4) RSA (sign only)
* Keysize: 4096
* Expiration: choose a reasonable value, for example 2y for 2 years (it can be renewed)

Then answer a few questions:

* Your real name. You could use your GitHub username here if you’d like.
* Email address. If you plan to use this key for more than just Git, you might want to put your real email address. If it’s just for GitHub, you can use the @users.noreply.github.com email that GitHub generates for you: you can find it on the Email settings page.
* You will be asked to type a passphrase which is used to encrypt your secret key on disk. This is important, otherwise attackers could steal your secret key, and then they’d be able to sign messages and Git commits pretending to be you.

You can verify your key was created with:

```
$ gpg --list-secret-keys --keyid-format SHORT

------------------------
sec   rsa4096/674CC45A 2020-05-16 [SC] [expires: 2024-05-16]
      65A8A7455C959E73FC3B7320316132F5674CB45A
uid         [ultimate] Meow-demo <3492+Meow@users.noreply.github.com>
```

In the example above, my new key ID is `rsa4096/674CC45A`, or just`674CC45A`.

You can confirm that GPG is working and able to sign messages with:

```
echo "hello world" | gpg --clearsign
```

If your GPG agent is having issues, you can restart it with:

```
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

### Configure Git to sign your commits

Once you have your private key, you can configure Git to sign your commits with that:


```git config --global user.signingkey 674CC45A```

Now, you can sign Git commits and tags with:

* Add the `-S` flag when creating a commit: `git commit -S`
* Create a tag with `git tag -s` rather than `git tag -a`

You can also tell Git to automatically sign all your commits:
```
git config --global commit.gpgSign true
git config --global tag.gpgSign true
```

### Adding the GPG key to GitHub

In order for GitHub to accept your GPG key and show your commits as 'verified', you first need to ensure that the email address you use when committing a code change is both included in the GPG key and verified on GitHub.

To set what email address Git uses when creating a commit use:


```git config --global user.email your@email.com```

You can use your @users.noreply.github.com email (from the Email settings page on GitHub) or any other email address that is added to your GitHub account and verified (in the same settings page).

If it’s not already, that same email address must also be added to your GPG key, as per instructions above.

Once you’ve done it, upload your public GPG key to GitHub and associate it with your account. In the SSH and GPG Keys settings page, add a new GPG key and paste your public key, which you can get with:

`gpg --armor --export 674CB45A`

Your public GPG key begins with `-----BEGIN PGP PUBLIC KEY BLOCK-----` and ends with `-----END PGP PUBLIC KEY BLOCK-----`.

#### Making a signed commit

After configuring all of the above, your Git commits can now be signed with your GPG key:

* Add the `-S` flag if you did not configure Git to sign commits by default
* `git commit -a -m "Pushing my first signed commit"`

You can check that the commit was signed with:

```bash
$ git log --show-signature -1
commit 8beed807e820d34cc7a81b3ee9913bed7b1b03 (HEAD -> master)
gpg: Signature made Sun May 21 01:44:55 2024 UTC
gpg:                using RSA key 674CC45A
gpg: Good signature from "Meow-demo <3492+Meow.noreply.github.com>" [ultimate]
Author: ItalyPaleAle-demo <3492+Meow@users.noreply.github.com>
Date:   Sun May 21 01:44:55 2024 +0000

    Making my first signed commit
```
 
 ## References
 
 * https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits
 * https://inspeerity.com/blog/signing-git-commits