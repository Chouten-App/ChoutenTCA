//
//  TargetScript+Actions.swift
//  ProjectDescriptionHelpers
//
//  Created by ErrorErrorError on 2/2/24.
//
//

import ProjectDescription

extension TargetScript {
  public static var swiftLint: TargetScript {
    .pre(
      script: """
      export PATH="$PATH:/opt/homebrew/bin"
      if which swiftlint > /dev/null; then
        swiftlint --config ../../.swiftlint.yml ../..
      else
        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
      fi
      """,
      name: "SwiftLint",
      basedOnDependencyAnalysis: false,
      runForInstallBuildsOnly: false
    )
  }

  public static var swiftFormat: TargetScript {
    .pre(
      script: """
      export PATH="$PATH:/opt/homebrew/bin"
      if which swiftformat >/dev/null; then
          swiftformat --config ../../.swiftformat.yml --lint --lenient ../..
      else
          echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
      fi
      """,
      name: "SwiftFormat",
      basedOnDependencyAnalysis: false,
      runForInstallBuildsOnly: false
    )
  }
}
