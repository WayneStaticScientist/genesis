// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messsage_model.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetMesssageModelCollection on Isar {
  IsarCollection<int, MesssageModel> get messsageModels => this.collection();
}

final MesssageModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'MesssageModel',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'sent', type: IsarType.bool),
      IsarPropertySchema(name: 'synced', type: IsarType.bool),
      IsarPropertySchema(name: 'content', type: IsarType.string),
      IsarPropertySchema(name: 'senderId', type: IsarType.string),
      IsarPropertySchema(name: 'receiverId', type: IsarType.string),
      IsarPropertySchema(name: 'timestamp', type: IsarType.dateTime),
      IsarPropertySchema(name: 'fileUrl', type: IsarType.string),
      IsarPropertySchema(name: 'fileName', type: IsarType.string),
      IsarPropertySchema(name: 'fileType', type: IsarType.string),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, MesssageModel>(
    serialize: serializeMesssageModel,
    deserialize: deserializeMesssageModel,
    deserializeProperty: deserializeMesssageModelProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeMesssageModel(IsarWriter writer, MesssageModel object) {
  IsarCore.writeBool(writer, 1, value: object.sent);
  IsarCore.writeBool(writer, 2, value: object.synced);
  IsarCore.writeString(writer, 3, object.content);
  IsarCore.writeString(writer, 4, object.senderId);
  IsarCore.writeString(writer, 5, object.receiverId);
  IsarCore.writeLong(
    writer,
    6,
    object.timestamp.toUtc().microsecondsSinceEpoch,
  );
  {
    final value = object.fileUrl;
    if (value == null) {
      IsarCore.writeNull(writer, 7);
    } else {
      IsarCore.writeString(writer, 7, value);
    }
  }
  {
    final value = object.fileName;
    if (value == null) {
      IsarCore.writeNull(writer, 8);
    } else {
      IsarCore.writeString(writer, 8, value);
    }
  }
  {
    final value = object.fileType;
    if (value == null) {
      IsarCore.writeNull(writer, 9);
    } else {
      IsarCore.writeString(writer, 9, value);
    }
  }
  return object.id;
}

@isarProtected
MesssageModel deserializeMesssageModel(IsarReader reader) {
  final bool _sent;
  _sent = IsarCore.readBool(reader, 1);
  final bool _synced;
  {
    if (IsarCore.readNull(reader, 2)) {
      _synced = true;
    } else {
      _synced = IsarCore.readBool(reader, 2);
    }
  }
  final int _id;
  _id = IsarCore.readId(reader);
  final String _content;
  _content = IsarCore.readString(reader, 3) ?? '';
  final String _senderId;
  _senderId = IsarCore.readString(reader, 4) ?? '';
  final String _receiverId;
  _receiverId = IsarCore.readString(reader, 5) ?? '';
  final DateTime _timestamp;
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      _timestamp = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _timestamp = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final String? _fileUrl;
  _fileUrl = IsarCore.readString(reader, 7);
  final String? _fileName;
  _fileName = IsarCore.readString(reader, 8);
  final String? _fileType;
  _fileType = IsarCore.readString(reader, 9);
  final object = MesssageModel(
    sent: _sent,
    synced: _synced,
    id: _id,
    content: _content,
    senderId: _senderId,
    receiverId: _receiverId,
    timestamp: _timestamp,
    fileUrl: _fileUrl,
    fileName: _fileName,
    fileType: _fileType,
  );
  return object;
}

@isarProtected
dynamic deserializeMesssageModelProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readBool(reader, 1);
    case 2:
      {
        if (IsarCore.readNull(reader, 2)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 2);
        }
      }
    case 0:
      return IsarCore.readId(reader);
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 7:
      return IsarCore.readString(reader, 7);
    case 8:
      return IsarCore.readString(reader, 8);
    case 9:
      return IsarCore.readString(reader, 9);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _MesssageModelUpdate {
  bool call({
    required int id,
    bool? sent,
    bool? synced,
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
    String? fileUrl,
    String? fileName,
    String? fileType,
  });
}

class _MesssageModelUpdateImpl implements _MesssageModelUpdate {
  const _MesssageModelUpdateImpl(this.collection);

  final IsarCollection<int, MesssageModel> collection;

  @override
  bool call({
    required int id,
    Object? sent = ignore,
    Object? synced = ignore,
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
    Object? fileUrl = ignore,
    Object? fileName = ignore,
    Object? fileType = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (sent != ignore) 1: sent as bool?,
            if (synced != ignore) 2: synced as bool?,
            if (content != ignore) 3: content as String?,
            if (senderId != ignore) 4: senderId as String?,
            if (receiverId != ignore) 5: receiverId as String?,
            if (timestamp != ignore) 6: timestamp as DateTime?,
            if (fileUrl != ignore) 7: fileUrl as String?,
            if (fileName != ignore) 8: fileName as String?,
            if (fileType != ignore) 9: fileType as String?,
          },
        ) >
        0;
  }
}

sealed class _MesssageModelUpdateAll {
  int call({
    required List<int> id,
    bool? sent,
    bool? synced,
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
    String? fileUrl,
    String? fileName,
    String? fileType,
  });
}

class _MesssageModelUpdateAllImpl implements _MesssageModelUpdateAll {
  const _MesssageModelUpdateAllImpl(this.collection);

  final IsarCollection<int, MesssageModel> collection;

  @override
  int call({
    required List<int> id,
    Object? sent = ignore,
    Object? synced = ignore,
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
    Object? fileUrl = ignore,
    Object? fileName = ignore,
    Object? fileType = ignore,
  }) {
    return collection.updateProperties(id, {
      if (sent != ignore) 1: sent as bool?,
      if (synced != ignore) 2: synced as bool?,
      if (content != ignore) 3: content as String?,
      if (senderId != ignore) 4: senderId as String?,
      if (receiverId != ignore) 5: receiverId as String?,
      if (timestamp != ignore) 6: timestamp as DateTime?,
      if (fileUrl != ignore) 7: fileUrl as String?,
      if (fileName != ignore) 8: fileName as String?,
      if (fileType != ignore) 9: fileType as String?,
    });
  }
}

extension MesssageModelUpdate on IsarCollection<int, MesssageModel> {
  _MesssageModelUpdate get update => _MesssageModelUpdateImpl(this);

  _MesssageModelUpdateAll get updateAll => _MesssageModelUpdateAllImpl(this);
}

sealed class _MesssageModelQueryUpdate {
  int call({
    bool? sent,
    bool? synced,
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
    String? fileUrl,
    String? fileName,
    String? fileType,
  });
}

class _MesssageModelQueryUpdateImpl implements _MesssageModelQueryUpdate {
  const _MesssageModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<MesssageModel> query;
  final int? limit;

  @override
  int call({
    Object? sent = ignore,
    Object? synced = ignore,
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
    Object? fileUrl = ignore,
    Object? fileName = ignore,
    Object? fileType = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (sent != ignore) 1: sent as bool?,
      if (synced != ignore) 2: synced as bool?,
      if (content != ignore) 3: content as String?,
      if (senderId != ignore) 4: senderId as String?,
      if (receiverId != ignore) 5: receiverId as String?,
      if (timestamp != ignore) 6: timestamp as DateTime?,
      if (fileUrl != ignore) 7: fileUrl as String?,
      if (fileName != ignore) 8: fileName as String?,
      if (fileType != ignore) 9: fileType as String?,
    });
  }
}

extension MesssageModelQueryUpdate on IsarQuery<MesssageModel> {
  _MesssageModelQueryUpdate get updateFirst =>
      _MesssageModelQueryUpdateImpl(this, limit: 1);

  _MesssageModelQueryUpdate get updateAll =>
      _MesssageModelQueryUpdateImpl(this);
}

class _MesssageModelQueryBuilderUpdateImpl
    implements _MesssageModelQueryUpdate {
  const _MesssageModelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<MesssageModel, MesssageModel, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? sent = ignore,
    Object? synced = ignore,
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
    Object? fileUrl = ignore,
    Object? fileName = ignore,
    Object? fileType = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (sent != ignore) 1: sent as bool?,
        if (synced != ignore) 2: synced as bool?,
        if (content != ignore) 3: content as String?,
        if (senderId != ignore) 4: senderId as String?,
        if (receiverId != ignore) 5: receiverId as String?,
        if (timestamp != ignore) 6: timestamp as DateTime?,
        if (fileUrl != ignore) 7: fileUrl as String?,
        if (fileName != ignore) 8: fileName as String?,
        if (fileType != ignore) 9: fileType as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension MesssageModelQueryBuilderUpdate
    on QueryBuilder<MesssageModel, MesssageModel, QOperations> {
  _MesssageModelQueryUpdate get updateFirst =>
      _MesssageModelQueryBuilderUpdateImpl(this, limit: 1);

  _MesssageModelQueryUpdate get updateAll =>
      _MesssageModelQueryBuilderUpdateImpl(this);
}

extension MesssageModelQueryFilter
    on QueryBuilder<MesssageModel, MesssageModel, QFilterCondition> {
  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition> sentEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  idGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 6, value: value));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 6, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlBetween(String? lower, String? upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 8, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameBetween(String? lower, String? upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 8,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 8, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 8, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeBetween(String? lower, String? upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 9, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  fileTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 9, value: ''),
      );
    });
  }
}

extension MesssageModelQueryObject
    on QueryBuilder<MesssageModel, MesssageModel, QFilterCondition> {}

extension MesssageModelQuerySortBy
    on QueryBuilder<MesssageModel, MesssageModel, QSortBy> {
  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByContent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByContentDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySenderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySenderIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByReceiverId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  sortByReceiverIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByFileUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByFileUrlDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByFileName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByFileNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByFileType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByFileTypeDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension MesssageModelQuerySortThenBy
    on QueryBuilder<MesssageModel, MesssageModel, QSortThenBy> {
  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByContent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByContentDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySenderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySenderIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByReceiverId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  thenByReceiverIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByFileUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByFileUrlDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByFileName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByFileNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByFileType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByFileTypeDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension MesssageModelQueryWhereDistinct
    on QueryBuilder<MesssageModel, MesssageModel, QDistinct> {
  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct> distinctBySent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct> distinctByContent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctByReceiverId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct> distinctByFileUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctByFileType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }
}

extension MesssageModelQueryProperty1
    on QueryBuilder<MesssageModel, MesssageModel, QProperty> {
  QueryBuilder<MesssageModel, bool, QAfterProperty> sentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MesssageModel, bool, QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MesssageModel, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MesssageModel, String, QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MesssageModel, String, QAfterProperty> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<MesssageModel, String, QAfterProperty> receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<MesssageModel, DateTime, QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<MesssageModel, String?, QAfterProperty> fileUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<MesssageModel, String?, QAfterProperty> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<MesssageModel, String?, QAfterProperty> fileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension MesssageModelQueryProperty2<R>
    on QueryBuilder<MesssageModel, R, QAfterProperty> {
  QueryBuilder<MesssageModel, (R, bool), QAfterProperty> sentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MesssageModel, (R, bool), QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MesssageModel, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MesssageModel, (R, String), QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MesssageModel, (R, String), QAfterProperty> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<MesssageModel, (R, String), QAfterProperty>
  receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<MesssageModel, (R, DateTime), QAfterProperty>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<MesssageModel, (R, String?), QAfterProperty> fileUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<MesssageModel, (R, String?), QAfterProperty> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<MesssageModel, (R, String?), QAfterProperty> fileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension MesssageModelQueryProperty3<R1, R2>
    on QueryBuilder<MesssageModel, (R1, R2), QAfterProperty> {
  QueryBuilder<MesssageModel, (R1, R2, bool), QOperations> sentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, bool), QOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String), QOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String), QOperations>
  senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String), QOperations>
  receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, DateTime), QOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String?), QOperations>
  fileUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String?), QOperations>
  fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String?), QOperations>
  fileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}
