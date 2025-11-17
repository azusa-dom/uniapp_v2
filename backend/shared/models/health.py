"""Health management models"""
import uuid
from datetime import datetime, date
from decimal import Decimal
from sqlalchemy import (
    Column,
    String,
    DateTime,
    Date,
    Text,
    Boolean,
    Integer,
    Numeric,
    ForeignKey,
    CheckConstraint,
    Enum as SQLEnum,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import enum

from shared.database import Base


class MedicalRecord(Base):
    """Medical records"""
    __tablename__ = "medical_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    visit_date = Column(DateTime, nullable=False)
    hospital_name = Column(String(200))
    doctor_name = Column(String(100))
    department = Column(String(100))

    diagnosis = Column(Text)
    symptoms = Column(Text)
    treatment = Column(Text)
    notes = Column(Text)

    documents = Column(JSONB)  # [{"type": "report", "url": "..."}]

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    prescriptions = relationship("Prescription", back_populates="medical_record")

    def __repr__(self):
        return f"<MedicalRecord(user={self.user_id}, date={self.visit_date})>"


class Prescription(Base):
    """Prescriptions"""
    __tablename__ = "prescriptions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    medical_record_id = Column(UUID(as_uuid=True), ForeignKey("medical_records.id", ondelete="SET NULL"))

    medication_name = Column(String(200), nullable=False)
    dosage = Column(String(100))
    frequency = Column(String(100))  # "每日三次，餐后服用"
    duration = Column(String(100))  # "连续7天"

    start_date = Column(Date, nullable=False)
    end_date = Column(Date)

    prescribed_by = Column(String(100))
    notes = Column(Text)

    # Reminders
    reminder_enabled = Column(Boolean, default=True)
    reminder_times = Column(JSONB)  # ["08:00", "12:00", "18:00"]

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    medical_record = relationship("MedicalRecord", back_populates="prescriptions")

    def __repr__(self):
        return f"<Prescription(medication={self.medication_name}, user={self.user_id})>"


class HealthMetric(Base):
    """Daily health metrics"""
    __tablename__ = "health_metrics"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    metric_date = Column(Date, nullable=False)

    sleep_hours = Column(Numeric(4, 2))
    steps_count = Column(Integer)
    stress_level = Column(Integer)  # 0-10
    mood = Column(Integer)  # 1-5 (1=very bad, 5=very good)
    weight_kg = Column(Numeric(5, 2))

    notes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        CheckConstraint("stress_level >= 0 AND stress_level <= 10", name="valid_stress_level"),
        CheckConstraint("mood >= 1 AND mood <= 5", name="valid_mood"),
    )

    def __repr__(self):
        return f"<HealthMetric(user={self.user_id}, date={self.metric_date})>"


class AppointmentStatus(str, enum.Enum):
    """Appointment status"""
    SCHEDULED = "scheduled"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    RESCHEDULED = "rescheduled"


class MedicalAppointment(Base):
    """Medical appointments"""
    __tablename__ = "medical_appointments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    appointment_date = Column(DateTime, nullable=False)
    doctor_name = Column(String(100))
    department = Column(String(100))
    hospital_name = Column(String(200))

    reason = Column(Text)
    status = Column(SQLEnum(AppointmentStatus), default=AppointmentStatus.SCHEDULED)
    reminder_sent = Column(Boolean, default=False)
    notes = Column(Text)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<MedicalAppointment(user={self.user_id}, date={self.appointment_date})>"
