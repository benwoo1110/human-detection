from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from database_create import Data

class Database:
	def start_session():
		engine = create_engine('sqlite:///database.db', echo=True)
		session = sessionmaker(bind=engine)
		return session()

	def add_data(time, duration, num_today):
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		session.add(Data(time, duration, num_today))
		session.commit()

	def read_data():
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		all_data = session.query(Data).all()

		for data in all_data:
			print (data.time, data.duration, data.num_today)

	def clear_data():
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		all_data = session.query(Data).all()

		session.delete(all_data)
		session.commit()

	def delete_data(time):
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		rm_data = session.query(Aata).filter(Data.time==time).first()

		session.delete(rm_data)
		session.commit()

	def send_data():
		engine = create_engine('sqlite:///database.db', echo=True)
		Session = sessionmaker(bind=engine)
		session = Session()

		send_data = {"time":[], "duration":[], "num_today":[]}
		all_data = session.query(Data).all()

		for data in all_data:
			send_data["time"].append(str(data.time))
			send_data["duration"].append(str(data.duration))
			send_data["num_today"].append(str(data.num_today))
		#print (send_data)
		return send_data
