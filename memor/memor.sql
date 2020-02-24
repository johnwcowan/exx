CREATE TABLE IF NOT EXISTS views(
  viewid VARCHAR NOT NULL,
  viewname VARCHAR NOT NULL,
  grouping_catid VARCHAR NOT NULL,
  ordering_catid VARCHAR NOT NULL,
  asc_desc SMALLINT NOT NULL,
    PRIMARY KEY (viewid),
    FOREIGN KEY (grouping_catid) REFERENCES cats(catid),
    FOREIGN KEY (ordering_catid) REFERENCES cats(catid),
    UNIQUE (viewname))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS items(
  itemid VARCHAR NOT NULL,
  parent VARCHAR,
  note CLOB NOT NULL,
  text CLOB NOT NULL,
    PRIMARY KEY (itemid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS cats(
  catid VARCHAR NOT NULL,
  parent VARCHAR,
  catname VARCHAR NOT NULL,
  mut_excl_children SMALLINT NOT NULL,
  trashed SMALLINT NOT NULL,
  action CLOB NOT NULL,
    PRIMARY KEY (catid),
    FOREIGN KEY (parent) REFERENCES cats (catid),
    UNIQUE (catname))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS view_selection(
  viewid VARCHAR NOT NULL,
  catid VARCHAR NOT NULL,
  cat_negated SMALLINT NOT NULL,
    PRIMARY KEY (viewid, catid),
    FOREIGN KEY (viewid) REFERENCES views(viewid),
    FOREIGN KEY (catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS view_columns(
  viewid VARCHAR NOT NULL,
  catid VARCHAR NOT NULL,
  column_ordinal INTEGER NOT NULL,
    PRIMARY KEY (viewid, catid),
    FOREIGN KEY (viewid) REFERENCES views(viewid),
    FOREIGN KEY (catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS item_cats(
  itemid VARCHAR NOT NULL,
  catid VARCHAR NOT NULL,
  value VARCHAR,
  source VARCHAR NOT NULL,
    PRIMARY KEY (itemid, catid),
    FOREIGN KEY (itemid) REFERENCES items(itemid),
    FOREIGN KEY (catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS item_props(
  itemid VARCHAR NOT NULL,
  propid VARCHAR NOT NULL,
  value NOT NULL,
    PRIMARY KEY (itemid, propid),
    FOREIGN KEY (itemid) REFERENCES items(itemid),
    FOREIGN KEY (propid) REFERENCES props(propid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS cat_rules(
  catid VARCHAR NOT NULL,
  existing_catid VARCHAR NOT NULL,
  negated SMALLINT NOT NULL,
    PRIMARY KEY (catid, existing_catid),
    FOREIGN KEY (catid) REFERENCES cats(catid),
    FOREIGN KEY (existing_catid) REFERENCES existing_catids(existing_catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS numeric_cats(
  catid VARCHAR NOT NULL,
  propid VARCHAR NOT NULL,
  low_value NUMERIC NOT NULL,
  high_value NUMERIC NOT NULL,
    PRIMARY KEY (catid, propid),
    FOREIGN KEY (catid) REFERENCES cats(catid),
    FOREIGN KEY (propid) REFERENCES propids(propid))
    WITHOUT ROWID;

CREATE VIEW IF NOT EXISTS complete_views AS
  SELECT viewid, viewname, grouping_catid, ordering_catid, asc_desc,
         view_selection.catid as selection_catid, negated,
         view_columns.catid as column_catid, column_ordinal
  FROM views
  LEFT JOIN view_selection USING (viewid)
  LEFT JOIN view_columns USING (viewid);

CREATE VIEW IF NOT EXISTS complete_items AS
  SELECT items.itemid, modified_date, due_date, other_date, note, text,
         catid, source, propid, value
  FROM items
  LEFT JOIN item_cats USING (itemid)
  LEFT JOIN item_props USING (itemid);

