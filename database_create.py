from sqlalchemy import create_engine, ForeignKey
from sqlalchemy import Column, Date, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, backref

engine = create_engine('sqlite:///database.db', echo=True)
Base = declarative_base()

class Data(Base):
	__tablename__ = "Data"

	id = Column(Integer, primary_key=True)

	year = Column(String)
	month = Column(String)
	day = Column(String)
	time = Column(String)
	duration = Column(String)

	def __init__(self, year, month, day, time, duration):
		self.year = year
		self.month = month
		self.day = day
		self.time = time
		self.duration = duration

# create tables
Base.metadata.create_all(engine)
