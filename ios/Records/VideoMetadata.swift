//
//  VideoMetadata.swift
//  Pods
//
//  Created by snowlee on 4/24/25.
//
import ExpoModulesCore

// swiftlint:disable redundant_optional_initialization - Initialization with nil is necessary
internal struct VideoMetadata: Record {
  @Field
  var title: String? = nil

  @Field
  var artist: String? = nil

  @Field
  var artwork: URL? = nil
}
// swiftlint:enable redundant_optional_initialization

