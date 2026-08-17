# Releasing npm packages

The npm packages are versioned and published together with
[Changesets](https://github.com/changesets/changesets). Releases are explicit:
commit messages no longer decide versions, and packages no longer race in
separate workflows.

## Add release intent to a pull request

Run:

```sh
pnpm changeset
```

Choose every public package affected by the change, select a semantic-version
bump, and write a short consumer-facing summary. Commit the generated Markdown
file with the change.

Changesets updates internal dependency ranges when required. For example, a
breaking `@wordclock/canvas` version also schedules a compatible
`@wordclock/react` release.

## Publish

Feature work is merged into `develop`. When `develop` is promoted to `main`, the
`Release packages` workflow does one of two things:

1. If unreleased changesets exist, it opens or updates a **Version Packages**
   pull request containing version, changelog, and dependency-range updates.
2. Once that pull request is merged, it validates, builds, and publishes every
   unpublished package version, then creates package-specific Git tags and
   GitHub releases.

No manual version editing or package-level publish script is needed.

For local inspection, `pnpm release:status` shows the pending release plan and
`pnpm release:version` applies it to the working tree without publishing.

## npm trusted publishing

Configure a GitHub Actions trusted publisher for each public npm package:

- Repository owner: `simonheys`
- Repository: `wordclock`
- Workflow filename: `release.yml`
- Environment: leave empty unless the workflow is later given a matching GitHub
  environment
- Allowed action: `npm publish`

The workflow grants `id-token: write` and uses a compatible Node, npm, and pnpm
toolchain. npm therefore uses a short-lived OIDC credential and automatically
attaches provenance; it does not need an `NPM_TOKEN` secret.

After verifying the first trusted publication, set each package's publishing
access to require two-factor authentication and disallow tokens.

### First publication under a new scope

npm configures trusted publishers from an existing package's settings. A newly
named package must therefore be published once by an organization owner before
the trusted publisher can be attached. Review the package archive with
`npm pack --dry-run`, publish it with `npm publish --access public` and 2FA, then
configure the trusted publisher above before merging the first **Version
Packages** pull request.

Never add a long-lived npm automation token to this repository.
