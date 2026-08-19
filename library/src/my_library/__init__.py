"""my_library — public API surface.

Re-export every symbol that consumers of this library should be able to
import directly from `my_library`. Keep this file as the single source of
truth for the public interface.

Example:
    from my_library import add
"""

from my_library.example import add

__all__ = ["add"]
