class Dog

    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        self.name = name
        self.breed = breed
        self.id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name STRING,
                breed STRING
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        dog = DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(num)
        sql = "SELECT * FROM dogs WHERE id =? LIMIT 1"
        found_dog = DB[:conn].execute(sql, num).flatten
        dog = self.new(id: found_dog[0], name: found_dog[1], breed: found_dog[2])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
        if !dog.empty?
            new_dog = self.new_from_db(dog)
        else
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name =? LIMIT 1"
        found_dog = DB[:conn].execute(sql, name).flatten
        dog = self.new(id: found_dog[0], name: found_dog[1], breed: found_dog[2])
    end
    
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end