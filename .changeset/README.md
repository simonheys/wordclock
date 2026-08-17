# Changesets

Any pull request that changes a published package should include a changeset:

```sh
pnpm changeset
```

Select the affected packages, choose their semantic-version bumps, and describe
the consumer-visible change. Documentation, tests, examples, and release
infrastructure changes do not need a changeset unless they alter a published
package.

Changes are integrated through `develop`. When `develop` is promoted to `main`,
the release workflow opens or updates a reviewable **Version Packages** pull
request. Merging that pull request publishes the packages to npm and creates
package-specific Git tags and GitHub releases.

See [`RELEASING.md`](../RELEASING.md) for setup and recovery instructions.
