CREATE TABLE train_timetable (
    id SERIAL PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    osaka_departure_time VARCHAR(10) NOT NULL,
    osaka_platform VARCHAR(10),
    train_type VARCHAR(50),
    destination VARCHAR(50),
    direction VARCHAR(100),
    arrival_status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_timetable_station ON train_timetable(station_name);
