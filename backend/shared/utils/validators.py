"""
Validation utilities
"""
import re
from typing import Optional
from email_validator import validate_email as _validate_email, EmailNotValidError


def validate_email(email: str) -> bool:
    """
    Validate email address

    Args:
        email: Email address to validate

    Returns:
        True if valid, False otherwise
    """
    try:
        _validate_email(email)
        return True
    except EmailNotValidError:
        return False


def validate_ucl_email(email: str) -> bool:
    """
    Validate UCL email address

    Args:
        email: Email address to validate

    Returns:
        True if valid UCL email, False otherwise
    """
    if not validate_email(email):
        return False
    return email.lower().endswith("@ucl.ac.uk") or email.lower().endswith("@live.ucl.ac.uk")


def validate_password_strength(password: str) -> tuple[bool, Optional[str]]:
    """
    Validate password strength

    Requirements:
    - At least 8 characters
    - At least one uppercase letter
    - At least one lowercase letter
    - At least one digit
    - At least one special character

    Args:
        password: Password to validate

    Returns:
        Tuple of (is_valid, error_message)
    """
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"

    if not re.search(r"[A-Z]", password):
        return False, "Password must contain at least one uppercase letter"

    if not re.search(r"[a-z]", password):
        return False, "Password must contain at least one lowercase letter"

    if not re.search(r"\d", password):
        return False, "Password must contain at least one digit"

    if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
        return False, "Password must contain at least one special character"

    return True, None


def sanitize_input(text: str, max_length: int = 1000) -> str:
    """
    Sanitize user input by removing potentially harmful characters

    Args:
        text: Input text to sanitize
        max_length: Maximum allowed length

    Returns:
        Sanitized text
    """
    if not text:
        return ""

    # Trim to max length
    text = text[:max_length]

    # Remove null bytes
    text = text.replace("\x00", "")

    # Strip leading/trailing whitespace
    text = text.strip()

    return text
