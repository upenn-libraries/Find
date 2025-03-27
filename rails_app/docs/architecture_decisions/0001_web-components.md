# Web Components: Reusable designs such as the header and footer

## Date
2025-03-27

## Status
`Accepted`

## Context
Find should look and feel like it's a Penn Libraries website. When done well, this builds trust with people who visit the website since they know where they are and that the site's content is credible.

Penn Libraries uses a design system as the central place for our web design standards and reusable design patterns, and the way those reusable designs are distributed to websites like Find, is as web components.

[MDN Web Docs says Web Components](https://developer.mozilla.org/en-US/docs/Web/API/Web_components) are "... a suite of different technologies allowing you to create reusable custom elements — with their functionality encapsulated away from the rest of your code — and utilize them in your web apps."

Design system reusable designs generally refer to reusable in the sense that they are applicable to three or more of our Penn Libraries websites. 

[Design system documentation](https://upennlibrary.atlassian.net/wiki/spaces/designsystem/overview) is available on our Confluence intranet.

## Decision
Find uses the design system's reusable designs where applicable via web components such as the header, footer, and chat.

Find pins to a major version of the web components ([following semantic versioning](https://semver.org/)), so that minor and patch changes are released to Find independent of Find releases.

## Consequences

- Find can let the design system be responsible for maintaining reusable web designs, when typically those kinds of user interface elements would be unique and maintained within the local codebase.
- Version releases to web components are released independent of Find releases, but do depend on semantic versioning. 
- If a web component doesn't support needs of Find, then coordination with the design system is needed to either (a) include needs of Find in the web component or (b) replace the web component in Find with a local solution.
