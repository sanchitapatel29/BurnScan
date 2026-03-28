enum ReportFileType {
  pdf('PDF', 'pdf'),
  image('Image', 'png');

  const ReportFileType(this.label, this.extension);

  final String label;
  final String extension;
}
