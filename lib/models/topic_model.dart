enum ContentBlockType {
  heading,
  subheading,
  body,
  bullet,
  numbered,
  code,
  infoBox,
  warningBox,
  quote,
  divider,
  image,
}

class ContentBlock {
  final ContentBlockType type;
  final String content;

  const ContentBlock({required this.type, required this.content});

  const ContentBlock.heading(this.content) : type = ContentBlockType.heading;
  const ContentBlock.subheading(this.content)
    : type = ContentBlockType.subheading;
  const ContentBlock.body(this.content) : type = ContentBlockType.body;
  const ContentBlock.bullet(this.content) : type = ContentBlockType.bullet;
  const ContentBlock.numbered(this.content) : type = ContentBlockType.numbered;
  const ContentBlock.code(this.content) : type = ContentBlockType.code;
  const ContentBlock.info(this.content) : type = ContentBlockType.infoBox;
  const ContentBlock.warning(this.content) : type = ContentBlockType.warningBox;
  const ContentBlock.quote(this.content) : type = ContentBlockType.quote;
  const ContentBlock.divider() : type = ContentBlockType.divider, content = '';
  const ContentBlock.image(this.content) : type = ContentBlockType.image;

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? 'body';
    final content = json['content'] as String? ?? '';

    ContentBlockType type;
    switch (typeString) {
      case 'heading':
        type = ContentBlockType.heading;
        break;
      case 'subheading':
        type = ContentBlockType.subheading;
        break;
      case 'body':
        type = ContentBlockType.body;
        break;
      case 'bullet':
        type = ContentBlockType.bullet;
        break;
      case 'numbered':
        type = ContentBlockType.numbered;
        break;
      case 'code':
        type = ContentBlockType.code;
        break;
      case 'infoBox':
        type = ContentBlockType.infoBox;
        break;
      case 'warningBox':
        type = ContentBlockType.warningBox;
        break;
      case 'divider':
        type = ContentBlockType.divider;
        break;
      case 'image':
        type = ContentBlockType.image;
        break;
      case 'quote':
        type = ContentBlockType.quote;
        break;
      default:
        type = ContentBlockType.body;
        break;
    }

    if (type == ContentBlockType.divider) {
      return const ContentBlock.divider();
    }

    return ContentBlock(type: type, content: content);
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case ContentBlockType.heading:
        typeString = 'heading';
        break;
      case ContentBlockType.subheading:
        typeString = 'subheading';
        break;
      case ContentBlockType.body:
        typeString = 'body';
        break;
      case ContentBlockType.bullet:
        typeString = 'bullet';
        break;
      case ContentBlockType.numbered:
        typeString = 'numbered';
        break;
      case ContentBlockType.code:
        typeString = 'code';
        break;
      case ContentBlockType.infoBox:
        typeString = 'infoBox';
        break;
      case ContentBlockType.warningBox:
        typeString = 'warningBox';
        break;
      case ContentBlockType.divider:
        typeString = 'divider';
        break;
      case ContentBlockType.quote:
        typeString = 'quote';
        break;
      case ContentBlockType.image:
        typeString = 'image';
        break;
    }

    return {
      'type': typeString,
      if (type != ContentBlockType.divider) 'content': content,
    };
  }
}

class Topic {
  final String id;
  final String title;
  final String subtitle;
  final List<ContentBlock> contentBlocks;
  final String? quizId;

  const Topic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.contentBlocks,
    this.quizId,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      contentBlocks: (json['contentBlocks'] as List<dynamic>? ?? [])
          .map((blockJson) =>
              ContentBlock.fromJson(blockJson as Map<String, dynamic>))
          .toList(),
      quizId: json['quizId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'contentBlocks': contentBlocks.map((b) => b.toJson()).toList(),
        'quizId': quizId,
      };
}
