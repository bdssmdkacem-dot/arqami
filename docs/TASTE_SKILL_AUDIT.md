# Arqami — Taste Skill Audit

## Design Read

Reading this as: a child-first Arabic educational app for ages 4–6, with a playful, calm, tactile interface language built on Flutter Material 3.

## Taste Skill application

Taste Skill is a frontend design/audit framework. Its web-specific stack rules are not copied into Flutter. The applicable principles are translated into Flutter UI decisions:

- audit before redesign;
- preserve existing educational content and accessibility wins;
- establish a coherent design system before local styling;
- avoid generic/template visual patterns;
- keep hierarchy, spacing, typography and motion intentional;
- let the audience and product constraints override decorative trends;
- use restrained motion and visual density appropriate for young children.

## Current findings

### High priority

1. `lib/main.dart` declares `fontFamily: 'Cairo'`, but `pubspec.yaml` does not currently register Cairo font assets. The production build should use a bundled, verified Arabic font or remove the unavailable family declaration.
2. The app needs a centralized child-focused design system so screens and game widgets do not drift into independent styling.
3. Android release configuration must be audited for current Google Play requirements before production submission.
4. Existing number paths are documented as approximate and need visual validation per digit.

### Preserve

- 13 educational units.
- Arabic RTL experience.
- Hive local progress.
- Arabic TTS architecture.
- Existing game types and educational progression.
- Existing AdMob integration, subject to child-directed compliance review.

## Proposed implementation order

1. Establish design tokens and typography.
2. Audit/rework Units Map screen.
3. Audit/rework Unit Player shell and feedback states.
4. Audit each game widget without changing learning objectives.
5. Validate tracing paths and touch targets.
6. Validate TTS feedback and graceful fallback.
7. Review ads placement so ads do not interrupt core learning.
8. Review Android release/target API and CI.
9. Add regression/widget tests for critical interactions.
10. Build a release candidate and validate Closed Testing readiness.
