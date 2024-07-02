"use strict";
var source = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // src/testing.ts
  var testing_exports = {};
  __export(testing_exports, {
    default: () => TestModule
  });

  // src/types.ts
  var BaseModule = class {
  };

  // src/testing.ts
  var TestModule = class extends BaseModule {
    constructor() {
      super(...arguments);
      this.baseUrl = "https://baseurl.com";
      this.metadata = {
        id: "",
        name: "",
        author: "",
        description: "",
        type: 0 /* Source */,
        subtypes: [],
        version: ""
      };
      this.settings = {
        groups: [
          {
            title: "General",
            settings: [
              {
                id: "Domain",
                label: "Domain",
                placeholder: "https://domain.com",
                defaultValue: "",
                value: ""
              },
              {
                id: "Toggle",
                label: "Toggle",
                defaultValue: true,
                value: true
              }
            ]
          },
          {
            title: "Another Group",
            settings: [
              {
                id: "Number",
                label: "Number",
                placeholder: "20",
                defaultValue: 0,
                value: 0
              }
            ]
          }
        ]
      };
    }
    discover() {
      return Promise.resolve({
        listings: []
      });
    }
    search(query) {
      return Promise.resolve({
        data: []
      });
    }
    info(url) {
      return Promise.resolve({
        id: "",
        titles: {
          primary: "Primary",
          secondary: "Secondary"
        },
        tags: ["Tag 1"],
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
        banner: null,
        mediaType: 0 /* EPISODES */,
        status: 0 /* COMPLETED */,
        totalMediaCount: 12,
        seasons: []
      });
    }
    episodes(url) {
      return Promise.resolve(
        [
          {
            title: "Season 1",
            list: [
              {
                url: "",
                number: 1
              },
              {
                url: "",
                number: 2,
                title: "Title",
                image: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
              }
            ]
          }
        ]
      );
    }
    servers(url) {
      throw new Error("Method not implemented.");
    }
    sources() {
      throw new Error("Method not implemented.");
    }
  };
  return __toCommonJS(testing_exports);
})();
