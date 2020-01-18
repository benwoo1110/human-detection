from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from database_create import Data

class Database:
	def add_data(year, month, day, time, duration):
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		session.add(Data(year, month, day, time, duration))
		session.commit()
#		session.close()

	def read_data():
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		all_data = session.query(Data).all()

		for data in all_data:
			print (data.year, data.month, data.day, data.time, data.duration)

#		session.close()

	def clear_data():
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		all_data = session.query(Data).all()

		session.delete(all_data)
		session.commit()
#		session.close()

	def delete_data(time):
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		rm_data = session.query(Aata).filter(Data.time==time).first()

		session.delete(rm_data)
		session.commit()
#		session.close()

	def send_data():
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		send_data = {"year":[], "month":[], "day":[], "time":[], "duration":[]}
		all_data = session.query(Data).all()

		for data in all_data:
			send_data["year"].append(str(data.year))
			send_data["month"].append(str(data.month))
			send_data["day"].append(str(data.day))
			send_data["time"].append(str(data.time))
			send_data["duration"].append(str(data.duration))

#		session.close()

		return send_data
