# Repository Guidelines

## Project Structure & Module Organization
Ruby engine code stays in `lib/kpop`, while shipping assets and components live under `app`. UI components go in `app/components/kpop`, styles in `app/assets/stylesheets`, and Stimulus controllers plus utilities in `app/javascript/kpop` with `application.js` as the Rollup entry. Specs live in `spec/{components,requests,system}` and run against the mounted host inside `spec/dummy` for realistic modal flows.

## Build, Test, and Development Commands
- `bundle exec rake` runs linting (Rubocop, ERB, Prettier), JS/Sass builds, and the whole spec suite—treat it as the pre-push gate.
- `bundle exec rake spec` targets RSpec only when iterating on Ruby APIs.
- `bundle exec rake yarn:build` (or `yarn build`) emits the ES modules in `app/assets/builds/katalyst`.
- `bin/rails s` from `spec/dummy` boots the harness app for manual checks; keep Rollup running in another shell while debugging JS.

## Coding Style & Naming Conventions
Follow `rubocop-katalyst` (Ruby 3.2, two-space indent, frozen string literals) and keep modules namespaced (`Kpop::ModalComponent`). Use Prettier via `yarn exec prettier --write app/javascript` for ES modules and Stimulus controllers; files stay snake_case (`modal_controller.js`) while classes export in PascalCase. SASS files should `@use \"katalyst/kpop\"` so shared tokens load once.

## Testing Guidelines
RSpec drives coverage: `spec/components` for rendering logic, `spec/requests` for helpers, and `spec/system` (Cuprite + Capybara) for modal UX. Name files `*_spec.rb`, prefer describe blocks per class or behavior, and lean on FactoryBot + Faker for fixtures. Use the dummy app for routing-heavy cases and run `rails db:prepare` inside `spec/dummy` after schema changes. Pair new Stimulus behavior with a system spec to prove Turbo frame navigation remains stable.

## Commit & Pull Request Guidelines
Commits stay short, imperative, and focused (e.g., `Rails 8.1`, `Churn: update dependencies`); reference issue IDs when relevant. PRs should outline the change, call out `bundle exec rake` results, include UI screenshots/GIFs for modal tweaks, and state whether gem and npm artifacts both change. When public APIs move, update `katalyst-kpop.gemspec`, rerun `bundle`, and regenerate builds so reviewers check the shipped outputs.

## Release & Packaging Tips
For releases, bump `katalyst-kpop.gemspec`, run `bundle exec rake build` to refresh gem + JS artifacts, and confirm `app/assets/builds` contains current bundles. Tag (`git tag vX.Y.Z && git push --tags`) only after `bundle exec rake` passes so CI can publish to Rubygems and npm.

## Codex Sandbox Notes
- Full `bundle exec rake` passes only when the Codex sandbox allows unrestricted access (`danger-full-access`). This behavior has been confirmed as of the latest run.
