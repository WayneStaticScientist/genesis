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
      IsarPropertySchema(name: 'content', type: IsarType.string),
      IsarPropertySchema(name: 'senderId', type: IsarType.string),
      IsarPropertySchema(name: 'receiverId', type: IsarType.string),
      IsarPropertySchema(name: 'timestamp', type: IsarType.dateTime),
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
  IsarCore.writeString(writer, 1, object.content);
  IsarCore.writeString(writer, 2, object.senderId);
  IsarCore.writeString(writer, 3, object.receiverId);
  IsarCore.writeLong(
    writer,
    4,
    object.timestamp.toUtc().microsecondsSinceEpoch,
  );
  return object.id;
}

@isarProtected
MesssageModel deserializeMesssageModel(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String _content;
  _content = IsarCore.readString(reader, 1) ?? '';
  final String _senderId;
  _senderId = IsarCore.readString(reader, 2) ?? '';
  final String _receiverId;
  _receiverId = IsarCore.readString(reader, 3) ?? '';
  final DateTime _timestamp;
  {
    final value = IsarCore.readLong(reader, 4);
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
  final object = MesssageModel(
    id: _id,
    content: _content,
    senderId: _senderId,
    receiverId: _receiverId,
    timestamp: _timestamp,
  );
  return object;
}

@isarProtected
dynamic deserializeMesssageModelProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _MesssageModelUpdate {
  bool call({
    required int id,
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
  });
}

class _MesssageModelUpdateImpl implements _MesssageModelUpdate {
  const _MesssageModelUpdateImpl(this.collection);

  final IsarCollection<int, MesssageModel> collection;

  @override
  bool call({
    required int id,
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (content != ignore) 1: content as String?,
            if (senderId != ignore) 2: senderId as String?,
            if (receiverId != ignore) 3: receiverId as String?,
            if (timestamp != ignore) 4: timestamp as DateTime?,
          },
        ) >
        0;
  }
}

sealed class _MesssageModelUpdateAll {
  int call({
    required List<int> id,
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
  });
}

class _MesssageModelUpdateAllImpl implements _MesssageModelUpdateAll {
  const _MesssageModelUpdateAllImpl(this.collection);

  final IsarCollection<int, MesssageModel> collection;

  @override
  int call({
    required List<int> id,
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
  }) {
    return collection.updateProperties(id, {
      if (content != ignore) 1: content as String?,
      if (senderId != ignore) 2: senderId as String?,
      if (receiverId != ignore) 3: receiverId as String?,
      if (timestamp != ignore) 4: timestamp as DateTime?,
    });
  }
}

extension MesssageModelUpdate on IsarCollection<int, MesssageModel> {
  _MesssageModelUpdate get update => _MesssageModelUpdateImpl(this);

  _MesssageModelUpdateAll get updateAll => _MesssageModelUpdateAllImpl(this);
}

sealed class _MesssageModelQueryUpdate {
  int call({
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
  });
}

class _MesssageModelQueryUpdateImpl implements _MesssageModelQueryUpdate {
  const _MesssageModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<MesssageModel> query;
  final int? limit;

  @override
  int call({
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (content != ignore) 1: content as String?,
      if (senderId != ignore) 2: senderId as String?,
      if (receiverId != ignore) 3: receiverId as String?,
      if (timestamp != ignore) 4: timestamp as DateTime?,
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
    Object? content = ignore,
    Object? senderId = ignore,
    Object? receiverId = ignore,
    Object? timestamp = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (content != ignore) 1: content as String?,
        if (senderId != ignore) 2: senderId as String?,
        if (receiverId != ignore) 3: receiverId as String?,
        if (timestamp != ignore) 4: timestamp as DateTime?,
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
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
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
          property: 1,
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
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
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
          property: 1,
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
          property: 1,
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
          property: 1,
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
          property: 1,
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
          property: 1,
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
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
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
          property: 2,
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
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
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
          property: 2,
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
          property: 2,
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
          property: 2,
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
          property: 2,
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
          property: 2,
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
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdGreaterThan(String value, {bool caseSensitive = true}) {
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
  receiverIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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
  receiverIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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
  receiverIdBetween(String lower, String upper, {bool caseSensitive = true}) {
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
  receiverIdStartsWith(String value, {bool caseSensitive = true}) {
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
  receiverIdEndsWith(String value, {bool caseSensitive = true}) {
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
  receiverIdContains(String value, {bool caseSensitive = true}) {
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
  receiverIdMatches(String pattern, {bool caseSensitive = true}) {
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
  receiverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  receiverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 4, value: value));
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterFilterCondition>
  timestampBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower, upper: upper),
      );
    });
  }
}

extension MesssageModelQueryObject
    on QueryBuilder<MesssageModel, MesssageModel, QFilterCondition> {}

extension MesssageModelQuerySortBy
    on QueryBuilder<MesssageModel, MesssageModel, QSortBy> {
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
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByContentDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySenderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortBySenderIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByReceiverId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  sortByReceiverIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension MesssageModelQuerySortThenBy
    on QueryBuilder<MesssageModel, MesssageModel, QSortThenBy> {
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
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByContentDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySenderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenBySenderIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByReceiverId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  thenByReceiverIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension MesssageModelQueryWhereDistinct
    on QueryBuilder<MesssageModel, MesssageModel, QDistinct> {
  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct> distinctByContent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctByReceiverId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesssageModel, MesssageModel, QAfterDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension MesssageModelQueryProperty1
    on QueryBuilder<MesssageModel, MesssageModel, QProperty> {
  QueryBuilder<MesssageModel, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MesssageModel, String, QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MesssageModel, String, QAfterProperty> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MesssageModel, String, QAfterProperty> receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MesssageModel, DateTime, QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension MesssageModelQueryProperty2<R>
    on QueryBuilder<MesssageModel, R, QAfterProperty> {
  QueryBuilder<MesssageModel, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MesssageModel, (R, String), QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MesssageModel, (R, String), QAfterProperty> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MesssageModel, (R, String), QAfterProperty>
  receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MesssageModel, (R, DateTime), QAfterProperty>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension MesssageModelQueryProperty3<R1, R2>
    on QueryBuilder<MesssageModel, (R1, R2), QAfterProperty> {
  QueryBuilder<MesssageModel, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String), QOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String), QOperations>
  senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, String), QOperations>
  receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MesssageModel, (R1, R2, DateTime), QOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}
