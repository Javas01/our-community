String get communityCode {
  bool isProd = const bool.fromEnvironment('dart.vm.product');
  if (isProd) {
    return 'ATLMasjid';
  }

  return 'Test';
}
