from sqlalchemy import create_engine, ForeignKey
from sqlalchemy import Column, Date, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, backref

engine = create_engine('sqlite:///database.db', echo=True)
Base = declarative_base()

class Data(Base):
	__tablename__ = "Data"

	id = Column(Integer, primary_key=True)

	time = Column(String)
	duration = Column(String)
	num_today = Column(String)

	def __init__(self, time, duration, num_today):
		self.time = time
		self.duration = duration
		self.num_today = num_today

# create tables
Base.metadata.create_all(engine)
