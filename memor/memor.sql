PRAGMA foreign_keys = true;

CREATE TABLE IF NOT EXISTS views(
  viewid VARCHAR NOT NULL PRIMARY KEY,
  viewname VARCHAR NOT NULL UNIQUE,
  grouping_catid VARCHAR NOT NULL,
  ordering_catid VARCHAR NOT NULL,
  asc_desc SMALLINT NOT NULL,
    FOREIGN KEY (grouping_catid) REFERENCES cats(catid),
    FOREIGN KEY (ordering_catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS items(
  itemid VARCHAR NOT NULL PRIMARY KEY,
  note CLOB NOT NULL,
  text CLOB NOT NULL)
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS cats(
  catid VARCHAR NOT NULL PRIMARY KEY,
  parent VARCHAR,
  catname VARCHAR NOT NULL UNIQUE,
  mut_excl_children SMALLINT NOT NULL,
  action CLOB NOT NULL,
    FOREIGN KEY (parent) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS view_selection(
  viewid VARCHAR NOT NULL REFERENCES views(viewid),
  catid VARCHAR NOT NULL REFERENCES cats(catid),
  negated SMALLINT NOT NULL,
    PRIMARY KEY (viewid, catid),
    FOREIGN KEY (viewid) REFERENCES views(viewid),
    FOREIGN KEY (catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS view_columns(
  viewid VARCHAR NOT NULL,
  catid VARCHAR NOT NULL,
  column_ordinal INTEGER NOT NULL UNIQUE,
    PRIMARY KEY (viewid, catid),
    FOREIGN KEY (viewid) REFERENCES views(viewid),
    FOREIGN KEY (catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS item_cats(
  itemid VARCHAR NOT NULL,
  catid VARCHAR NOT NULL,
  strvalue VARCHAR,
  numvalue FLOAT,
  source VARCHAR NOT NULL,      -- user, hierarchy, date, rule, ai
    PRIMARY KEY (itemid, catid),
    FOREIGN KEY (itemid) REFERENCES items(itemid),
    FOREIGN KEY (catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS cat_rules(
  catid VARCHAR NOT NULL,
  source_catid VARCHAR NOT NULL,
  negated SMALLINT NOT NULL,
  relop VARCHAR NOT NULL,
  strvalue VARCHAR,      -- '', '=', '<', '>', 'START', 'END'
  numvalue FLOAT,
    PRIMARY KEY (catid, source_catid),
    FOREIGN KEY (catid) REFERENCES cats(catid),
    FOREIGN KEY (source_catid) REFERENCES cats(catid))
    WITHOUT ROWID;

CREATE VIEW IF NOT EXISTS complete_views AS
  SELECT viewid, viewname, grouping_catid, ordering_catid, asc_desc,
         view_selection.catid as selection_catid, negated,
         view_columns.catid as column_catid, column_ordinal
  FROM views
  LEFT JOIN view_selection USING (viewid)
  LEFT JOIN view_columns USING (viewid);

CREATE VIEW IF NOT EXISTS complete_items AS
  SELECT items.itemid, note, text, catid, source, strvalue, numvalue
  FROM items
  LEFT JOIN item_cats USING (itemid);

CREATE VIEW IF NOT EXISTS complete_cats AS
  SELECT cats.catid, parent, catname, mut_excl_children,
         source_catid, negated, relop, strvalue, numvalue
  FROM cats
  LEFT JOIN cat_rules USING (catid);
