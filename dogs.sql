CREATE TABLE dogs (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER NOT NULL,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER NOT NULL,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO houses (address) VALUES ("200 Cherry Rd");
INSERT INTO houses (address) VALUES ("300 Blossom St");

INSERT INTO humans (fname, lname, house_id) VALUES ("Bruce", "Wayne", 1);
INSERT INTO humans (fname, lname, house_id) VALUES ("Steve", "McQueen", 1);
INSERT INTO humans (fname, lname, house_id) VALUES ("Barack", "Obama", 2);

INSERT INTO dogs (name, owner_id) VALUES ("Spike", 1);
INSERT INTO dogs (name, owner_id) VALUES ("Mojo", 2);
INSERT INTO dogs (name, owner_id) VALUES ("Frank", 3);
INSERT INTO dogs (name, owner_id) VALUES ("Maya", 3);