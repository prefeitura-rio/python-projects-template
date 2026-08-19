"""Tests for my_library.example."""

from my_library import add


def test_add_positive_numbers() -> None:
    assert add(1, 2) == 3


def test_add_negative_numbers() -> None:
    assert add(-3, -4) == -7


def test_add_zero() -> None:
    assert add(0, 42) == 42
