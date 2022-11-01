class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end
    #delete  table if exists
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

    #create a table if it doen
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

    #map the class instances to table rows
  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  # saves a song to the database
  #   returns the new object that it instantiated
  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end
  
  #Class.new_from_db
    #takes an array representing a row from the database and returns a song
  def self.new_from_db(row)
    #self.new is equivalent to Song.new
    self.new(id: row[0], name: row[1], album: row[2])
  end

  #returns an array of all songs
  #Class.all  
  def self.all
    sql = <<-SQL
    SELECT *
    FROM songs
    SQL
    #make a call to our database using DB[:conn] in the environment
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

#  returns a song with the matching name
  #Class.find_by_name    
#include a name in our SQL statement, pass ? as a parameterand include name s the 2nd argument
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM songs
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end




end
