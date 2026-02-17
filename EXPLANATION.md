# Assignment Explanation

## What was the bug?
The bug was in the token refresh logic inside `Client.request()` when `api=True`.  
If the `oauth2_token` attribute was a **dictionary** (e.g., loaded from stale configuration) instead of an `OAuth2Token` object, the condition `if not self.oauth2_token or (isinstance(self.oauth2_token, OAuth2Token) and self.oauth2_token.expired)` would evaluate to `False`. As a result, the token was **never refreshed**, and later when the code tried to call `.as_header()` on the dictionary, an `AttributeError` was raised (or, in a patched test, the header was missing).

## Why did it happen?
The original condition only triggered a refresh in two scenarios:
- The token was `None`, **or**
- The token was an instance of `OAuth2Token` **and** it was expired.

If the token existed but was **not** an `OAuth2Token` (e.g., a dictionary, a string), neither condition matched, so the refresh was skipped. This was too lenient – it assumed that any non‑`None`, non‑`OAuth2Token` token was already valid, which is not safe when the token representation can change (e.g., after loading from a JSON cache).

## Why does your fix actually solve it?
The updated condition is:
```python
if not isinstance(self.oauth2_token, OAuth2Token) or self.oauth2_token.expired:
    self.refresh_oauth2()


## One realistic case / edge case your tests still don’t cover
The tests do not cover network-level failures during the `refresh_oauth2` call (e.g., the API being down), which would currently result in an unhandled exception or an invalid token state.
