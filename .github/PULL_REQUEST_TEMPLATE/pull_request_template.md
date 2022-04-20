Please confirm the following if submitting a new pack:

## New Pack Checklist
- [ ] The README includes any information necessary to run the application that is not encoded in the pack itself.
- [ ] The pack renders properly with `nomad-pack render <NAME>`
- [ ] The pack plans properly with `nomad-pack plan <NAME>`
- [ ] The pack runs properly with `nomad-pack runs <NAME>`
- [ ] If applicable, a screenshot of the running application is attached to the PR.
- [ ] The default variable values result in a syntactically valid pack.
- [ ] Non-default variables values have been tested. Conditional code paths in the template have been tested, and confirmed to render/plan properly.
- [ ] If applicable, the pack includes constraints necessary to run the pack safely (I.E. a linux-only constraint for applications that require linux).