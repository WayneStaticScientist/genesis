// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetNotificationModelCollection on Isar {
  IsarCollection<int, NotificationModel> get notificationModels =>
      this.collection();
}

final NotificationModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'NotificationModel',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'channenId', type: IsarType.string),
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'content', type: IsarType.string),
      IsarPropertySchema(name: 'type', type: IsarType.string),
      IsarPropertySchema(name: 'date', type: IsarType.dateTime),
      IsarPropertySchema(name: 'isRead', type: IsarType.bool),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, NotificationModel>(
    serialize: serializeNotificationModel,
    deserialize: deserializeNotificationModel,
    deserializeProperty: deserializeNotificationModelProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeNotificationModel(IsarWriter writer, NotificationModel object) {
  IsarCore.writeString(writer, 1, object.channenId);
  IsarCore.writeString(writer, 2, object.title);
  IsarCore.writeString(writer, 3, object.content);
  IsarCore.writeString(writer, 4, object.type);
  IsarCore.writeLong(writer, 5, object.date.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 6, value: object.isRead);
  return object.id;
}

@isarProtected
NotificationModel deserializeNotificationModel(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String _channenId;
  _channenId = IsarCore.readString(reader, 1) ?? '';
  final String _title;
  _title = IsarCore.readString(reader, 2) ?? '';
  final String _content;
  _content = IsarCore.readString(reader, 3) ?? '';
  final String _type;
  _type = IsarCore.readString(reader, 4) ?? '';
  final DateTime _date;
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _date = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _date = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final bool _isRead;
  _isRead = IsarCore.readBool(reader, 6);
  final object = NotificationModel(
    _id,
    channenId: _channenId,
    title: _title,
    content: _content,
    type: _type,
    date: _date,
    isRead: _isRead,
  );
  return object;
}

@isarProtected
dynamic deserializeNotificationModelProp(IsarReader reader, int property) {
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
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 6:
      return IsarCore.readBool(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _NotificationModelUpdate {
  bool call({
    required int id,
    String? channenId,
    String? title,
    String? content,
    String? type,
    DateTime? date,
    bool? isRead,
  });
}

class _NotificationModelUpdateImpl implements _NotificationModelUpdate {
  const _NotificationModelUpdateImpl(this.collection);

  final IsarCollection<int, NotificationModel> collection;

  @override
  bool call({
    required int id,
    Object? channenId = ignore,
    Object? title = ignore,
    Object? content = ignore,
    Object? type = ignore,
    Object? date = ignore,
    Object? isRead = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (channenId != ignore) 1: channenId as String?,
            if (title != ignore) 2: title as String?,
            if (content != ignore) 3: content as String?,
            if (type != ignore) 4: type as String?,
            if (date != ignore) 5: date as DateTime?,
            if (isRead != ignore) 6: isRead as bool?,
          },
        ) >
        0;
  }
}

sealed class _NotificationModelUpdateAll {
  int call({
    required List<int> id,
    String? channenId,
    String? title,
    String? content,
    String? type,
    DateTime? date,
    bool? isRead,
  });
}

class _NotificationModelUpdateAllImpl implements _NotificationModelUpdateAll {
  const _NotificationModelUpdateAllImpl(this.collection);

  final IsarCollection<int, NotificationModel> collection;

  @override
  int call({
    required List<int> id,
    Object? channenId = ignore,
    Object? title = ignore,
    Object? content = ignore,
    Object? type = ignore,
    Object? date = ignore,
    Object? isRead = ignore,
  }) {
    return collection.updateProperties(id, {
      if (channenId != ignore) 1: channenId as String?,
      if (title != ignore) 2: title as String?,
      if (content != ignore) 3: content as String?,
      if (type != ignore) 4: type as String?,
      if (date != ignore) 5: date as DateTime?,
      if (isRead != ignore) 6: isRead as bool?,
    });
  }
}

extension NotificationModelUpdate on IsarCollection<int, NotificationModel> {
  _NotificationModelUpdate get update => _NotificationModelUpdateImpl(this);

  _NotificationModelUpdateAll get updateAll =>
      _NotificationModelUpdateAllImpl(this);
}

sealed class _NotificationModelQueryUpdate {
  int call({
    String? channenId,
    String? title,
    String? content,
    String? type,
    DateTime? date,
    bool? isRead,
  });
}

class _NotificationModelQueryUpdateImpl
    implements _NotificationModelQueryUpdate {
  const _NotificationModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<NotificationModel> query;
  final int? limit;

  @override
  int call({
    Object? channenId = ignore,
    Object? title = ignore,
    Object? content = ignore,
    Object? type = ignore,
    Object? date = ignore,
    Object? isRead = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (channenId != ignore) 1: channenId as String?,
      if (title != ignore) 2: title as String?,
      if (content != ignore) 3: content as String?,
      if (type != ignore) 4: type as String?,
      if (date != ignore) 5: date as DateTime?,
      if (isRead != ignore) 6: isRead as bool?,
    });
  }
}

extension NotificationModelQueryUpdate on IsarQuery<NotificationModel> {
  _NotificationModelQueryUpdate get updateFirst =>
      _NotificationModelQueryUpdateImpl(this, limit: 1);

  _NotificationModelQueryUpdate get updateAll =>
      _NotificationModelQueryUpdateImpl(this);
}

class _NotificationModelQueryBuilderUpdateImpl
    implements _NotificationModelQueryUpdate {
  const _NotificationModelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<NotificationModel, NotificationModel, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? channenId = ignore,
    Object? title = ignore,
    Object? content = ignore,
    Object? type = ignore,
    Object? date = ignore,
    Object? isRead = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (channenId != ignore) 1: channenId as String?,
        if (title != ignore) 2: title as String?,
        if (content != ignore) 3: content as String?,
        if (type != ignore) 4: type as String?,
        if (date != ignore) 5: date as DateTime?,
        if (isRead != ignore) 6: isRead as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension NotificationModelQueryBuilderUpdate
    on QueryBuilder<NotificationModel, NotificationModel, QOperations> {
  _NotificationModelQueryUpdate get updateFirst =>
      _NotificationModelQueryBuilderUpdateImpl(this, limit: 1);

  _NotificationModelQueryUpdate get updateAll =>
      _NotificationModelQueryBuilderUpdateImpl(this);
}

extension NotificationModelQueryFilter
    on QueryBuilder<NotificationModel, NotificationModel, QFilterCondition> {
  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  idGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  idLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  idBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  channenIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  contentEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  contentLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  dateGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  dateGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  dateLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  dateLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  dateBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterFilterCondition>
  isReadEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }
}

extension NotificationModelQueryObject
    on QueryBuilder<NotificationModel, NotificationModel, QFilterCondition> {}

extension NotificationModelQuerySortBy
    on QueryBuilder<NotificationModel, NotificationModel, QSortBy> {
  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByChannenId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByChannenIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy> sortByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByContentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy> sortByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  sortByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension NotificationModelQuerySortThenBy
    on QueryBuilder<NotificationModel, NotificationModel, QSortThenBy> {
  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByChannenId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByChannenIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy> thenByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByContentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy> thenByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterSortBy>
  thenByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension NotificationModelQueryWhereDistinct
    on QueryBuilder<NotificationModel, NotificationModel, QDistinct> {
  QueryBuilder<NotificationModel, NotificationModel, QAfterDistinct>
  distinctByChannenId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterDistinct>
  distinctByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterDistinct>
  distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterDistinct>
  distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<NotificationModel, NotificationModel, QAfterDistinct>
  distinctByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }
}

extension NotificationModelQueryProperty1
    on QueryBuilder<NotificationModel, NotificationModel, QProperty> {
  QueryBuilder<NotificationModel, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NotificationModel, String, QAfterProperty> channenIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationModel, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationModel, String, QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationModel, String, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationModel, DateTime, QAfterProperty> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationModel, bool, QAfterProperty> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension NotificationModelQueryProperty2<R>
    on QueryBuilder<NotificationModel, R, QAfterProperty> {
  QueryBuilder<NotificationModel, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NotificationModel, (R, String), QAfterProperty>
  channenIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationModel, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationModel, (R, String), QAfterProperty>
  contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationModel, (R, String), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationModel, (R, DateTime), QAfterProperty>
  dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationModel, (R, bool), QAfterProperty> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension NotificationModelQueryProperty3<R1, R2>
    on QueryBuilder<NotificationModel, (R1, R2), QAfterProperty> {
  QueryBuilder<NotificationModel, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NotificationModel, (R1, R2, String), QOperations>
  channenIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationModel, (R1, R2, String), QOperations>
  titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationModel, (R1, R2, String), QOperations>
  contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationModel, (R1, R2, String), QOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationModel, (R1, R2, DateTime), QOperations>
  dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationModel, (R1, R2, bool), QOperations>
  isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
